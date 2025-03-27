#!/bin/bash

#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#---Description---
#Run git comands on all git subdirectories.

#---code---
#!/bin/bash

# Strict mode
set -uo pipefail

VERSION="1.1.0"
SCRIPT_NAME="Git Commander"
SCRIPT_DESCRIPTION="A tool to manage multiple git repositories recursively."

# --- Configuration ---
DEFAULT_COMMIT_MESSAGE="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
COMMIT_MESSAGE_SUMMARY_APP="llmdiffsummary" # Set to "" to disable

# --- Script State ---
ROOT_DIR="."
COMMIT_MESSAGE="$DEFAULT_COMMIT_MESSAGE"
VERBOSE=false
declare -A OPERATIONS=( [fetch]=false [pull]=false [stage]=false [commit]=false [status]=false )
ANY_OPERATION=false # Flag to track if any action other than help/version was requested

# Store results
declare -a successful_pushes=()
declare -a no_changes_commit=() # Renamed for clarity
declare -a no_changes_stage=()  # Renamed for clarity
declare -a failed_pushes=()
declare -a failed_commits=()
declare -a failed_stages=()
declare -a fetch_failed=()
declare -a pull_failed=()
declare -a git_errors=() # Generic git errors
declare -a not_git_repos=() # Directories processed that weren't git repos (less useful now with find)

# Overall script exit status
EXIT_STATUS=0

# --- Functions ---

# Print error message to stderr and set exit status
error_msg() {
    echo "❌ ERROR: $*" >&2
    EXIT_STATUS=1
}

# Print verbose message
verbose_msg() {
    [[ "$VERBOSE" = true ]] && echo "VERBOSE: $*"
}

# Print info message
info_msg() {
    echo "$*"
}

# Show version information
show_version() {
    echo "$SCRIPT_NAME version $VERSION"
    echo "$SCRIPT_DESCRIPTION"
}

# Show help message
show_help() {
    show_version
    echo
    echo "Usage: $0 [OPTIONS] [-d <directory>]"
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -v, --version       Show version information"
    echo "  -d, --directory DIR Specify the root directory to scan (default: current directory)"
    echo "  -s, --status        Show status of all git repositories"
    echo "  -f, --fetch         Fetch changes from remote repositories"
    echo "  -p, --pull          Pull changes from remote repositories (implies fetch)"
    echo "  -t, --stage         Stage all changes (add ., including untracked)"
    echo "  -c, --commit        Commit and push staged/unstaged/untracked changes"
    echo "  -m, --message MSG   Use MSG as the commit message (overrides default/summary)"
    echo "  -a, --all           Perform fetch, pull, stage, commit, and push"
    echo "      --verbose       Show detailed output for successful operations"
    echo
    echo "Examples:"
    echo "  $0                   # Default: Commit & push changes in current dir and subdirs"
    echo "  $0 -s -d ~/projects  # Show status of repos under ~/projects"
    echo "  $0 -a --verbose      # Fetch, pull, stage, commit, push everything verbosely"
    echo "  $0 -t                # Stage all changes in all repos"
    echo "  $0 -c -m \"Fix typo\"  # Commit & push with a specific message"
    echo
    echo "Notes:"
    echo " - The '--all' option implies fetch, pull, stage, and commit."
    echo " - The 'commit' operation automatically stages all changes first."
    echo " - If '$COMMIT_MESSAGE_SUMMARY_APP' is found and enabled, it's used to generate"
    echo "   commit messages unless -m is specified."
}

# Check if a directory has any git changes (staged, unstaged, untracked)
has_changes() {
    local dir="$1"
    # git status --porcelain returns output if there are changes
    if [[ -n "$(git -C "$dir" status --porcelain)" ]]; then
        return 0 # 0 means true (has changes) in Bash
    else
        return 1 # 1 means false (no changes)
    fi
}

# Function to check git status
check_status() {
    local dir="$1"
    local repo_name
    repo_name=$(basename "$dir")
    info_msg "--- Status for repository: $repo_name ($dir) ---"
    # Use git status directly for more user-friendly output
    if ! git -C "$dir" status; then
        error_msg "Failed to get status for $dir"
        git_errors+=("$dir: status check failed")
    fi
    echo # Add a newline for better separation
}

# Function to fetch changes
fetch_changes() {
    local dir="$1"
    local repo_name
    repo_name=$(basename "$dir")
    verbose_msg "Fetching changes in: $repo_name ($dir)"
    local output
    output=$(git -C "$dir" fetch --all --prune 2>&1)
    local fetch_status=$?
    if [[ $fetch_status -eq 0 ]]; then
        verbose_msg "✅ Fetch successful in $dir"
        # Optionally show output even on success if verbose and output exists
        [[ "$VERBOSE" = true && -n "$output" ]] && echo "$output"
    else
        error_msg "Fetch failed in $repo_name ($dir)"
        fetch_failed+=("$dir")
        # Log the actual error message
        git_errors+=("$dir: Fetch failed:\n$output")
    fi
    return $fetch_status
}

# Function to pull changes (only if fetch succeeded)
pull_changes() {
    local dir="$1"
    local repo_name
    repo_name=$(basename "$dir")
    verbose_msg "Pulling changes in: $repo_name ($dir)"
    local output
    # Pull usually implies fetching the current branch, but we fetched --all already.
    # We need to handle different scenarios like new branches, rebase config etc.
    # A simple `git pull` might be okay for many workflows.
    # Consider `git pull --rebase` or more specific strategies if needed.
    output=$(git -C "$dir" pull --ff-only 2>&1) # Attempt fast-forward first
    local pull_status=$?
    if [[ $pull_status -eq 0 ]]; then
        verbose_msg "✅ Pull successful (fast-forward) in $dir"
        [[ "$VERBOSE" = true && -n "$output" ]] && echo "$output"
    else
        # If ff-only failed, try a regular merge pull (could require user intervention)
        verbose_msg "Fast-forward pull failed for $dir, attempting merge pull..."
        output=$(git -C "$dir" pull 2>&1)
        pull_status=$?
        if [[ $pull_status -eq 0 ]]; then
            info_msg "✅ Pull successful (merge) in $dir"
            [[ "$VERBOSE" = true && -n "$output" ]] && echo "$output"
        else
            error_msg "Pull failed in $repo_name ($dir)"
            pull_failed+=("$dir")
            git_errors+=("$dir: Pull failed:\n$output")
        fi
    fi
    return $pull_status
}

# Function to stage changes
stage_changes() {
    local dir="$1"
    local repo_name
    repo_name=$(basename "$dir")
    verbose_msg "Checking for changes to stage in: $repo_name ($dir)"

    if has_changes "$dir"; then
        verbose_msg "Staging changes in $dir"
        local output
        output=$(git -C "$dir" add . 2>&1)
        local add_status=$?
        if [[ $add_status -eq 0 ]]; then
            verbose_msg "✅ Changes staged in $dir"
        else
            error_msg "Failed to stage changes in $repo_name ($dir)"
            failed_stages+=("$dir")
            git_errors+=("$dir: Staging (git add .) failed:\n$output")
            return 1
        fi
    else
        verbose_msg "No changes to stage in $dir"
        no_changes_stage+=("$dir")
    fi
    return 0
}


# Function to commit and push changes
commit_and_push_changes() {
    local dir="$1"
    local repo_name
    repo_name=$(basename "$dir")
    verbose_msg "Checking for changes to commit in: $repo_name ($dir)"

    # Stage changes first (commit implies stage)
    if ! stage_changes "$dir"; then
        # staging failed, error already reported by stage_changes
        return 1
    fi

    # Check again specifically if there's anything staged for commit
    # `git diff --cached --quiet` checks if the staging area is different from HEAD
    if ! git -C "$dir" diff --cached --quiet; then
        info_msg "Committing changes in $repo_name ($dir)"

        # Determine commit message
        local current_commit_message="$COMMIT_MESSAGE" # Use script-level override if set via -m
        if [[ "$COMMIT_MESSAGE" == "$DEFAULT_COMMIT_MESSAGE" && -n "$COMMIT_MESSAGE_SUMMARY_APP" ]]; then
            if command -v "$COMMIT_MESSAGE_SUMMARY_APP" &> /dev/null; then
                verbose_msg "Generating commit summary using $COMMIT_MESSAGE_SUMMARY_APP for $dir"
                local summary
                # Get diff of staged changes against HEAD
                summary=$(git -C "$dir" diff --cached | "$COMMIT_MESSAGE_SUMMARY_APP" 2>&1)
                local summary_status=$?
                 if [[ $summary_status -eq 0 && -n "$summary" ]]; then
                    # Use summary only if command succeeded and output is not empty
                    current_commit_message="$summary"
                    verbose_msg "Using generated summary as commit message."
                elif [[ $summary_status -ne 0 ]]; then
                     error_msg "Commit summary generation failed for $dir: $summary"
                     # Fall back to default message
                fi
            else
                verbose_msg "Commit summary app '$COMMIT_MESSAGE_SUMMARY_APP' not found. Using default message."
            fi
        fi

        # Commit
        local commit_output
        commit_output=$(git -C "$dir" commit -m "$current_commit_message" 2>&1)
        local commit_status=$?
        if [[ $commit_status -eq 0 ]]; then
            verbose_msg "✅ Commit successful in $dir"

            # Push
            verbose_msg "Pushing changes in $dir"
            local push_output
            push_output=$(git -C "$dir" push 2>&1)
            local push_status=$?
            if [[ $push_status -eq 0 ]]; then
                info_msg "✅ Changes committed and pushed in $repo_name ($dir)"
                successful_pushes+=("$dir")
            else
                error_msg "Push failed in $repo_name ($dir)"
                failed_pushes+=("$dir")
                git_errors+=("$dir: Push failed:\n$push_output")
                return 1 # Mark repo as failed
            fi
        else
            error_msg "Commit failed in $repo_name ($dir)"
            failed_commits+=("$dir")
            git_errors+=("$dir: Commit failed:\n$commit_output")
            return 1 # Mark repo as failed
        fi
    else
         # This case happens if staging succeeded but resulted in no actual changes compared to HEAD
         # Or if stage_changes found nothing to stage originally.
        verbose_msg "No staged changes to commit in $dir"
        no_changes_commit+=("$dir")
    fi
    return 0
}

# Print summary array helper
print_summary_array() {
    local title="$1"
    shift
    local -a arr=("$@")
    local count=${#arr[@]}

    if [[ $count -gt 0 ]]; then
        echo -e "\n$title: $count"
        # Print details only if verbose or if it's a failure array
        if [[ "$VERBOSE" = true || "$title" == *"Failed"* || "$title" == *"Errors"* ]]; then
             printf '  %s\n' "${arr[@]}"
        fi
    fi
}

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        -v|--version) show_version; exit 0 ;;
        -d|--directory) ROOT_DIR="$2"; shift ;;
        -s|--status) OPERATIONS[status]=true; ANY_OPERATION=true ;;
        -f|--fetch) OPERATIONS[fetch]=true; ANY_OPERATION=true ;;
        -p|--pull) OPERATIONS[fetch]=true; OPERATIONS[pull]=true; ANY_OPERATION=true ;; # Pull implies fetch
        -t|--stage) OPERATIONS[stage]=true; ANY_OPERATION=true ;;
        -c|--commit) OPERATIONS[commit]=true; ANY_OPERATION=true ;; # Commit implies stage
        -m|--message) COMMIT_MESSAGE="$2"; ANY_OPERATION=true; shift ;;
        -a|--all)
            OPERATIONS[fetch]=true
            OPERATIONS[pull]=true
            OPERATIONS[stage]=true # Commit implies stage, but we might want stage separate
            OPERATIONS[commit]=true
            ANY_OPERATION=true
             ;;
        --verbose) VERBOSE=true ;;
        *) echo "Unknown parameter: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Default action if no operation specified
if [[ "$ANY_OPERATION" = false ]]; then
    info_msg "No operation specified, defaulting to --commit."
    OPERATIONS[commit]=true
fi

# Ensure the root directory exists
if [[ ! -d "$ROOT_DIR" ]]; then
    error_msg "Specified root directory '$ROOT_DIR' does not exist or is not a directory."
    exit 1
fi

# --- Main Execution Logic ---
info_msg "Starting Git Commander in directory: $ROOT_DIR"
info_msg "Operations: ${!OPERATIONS[@]}" # Show planned operations

# Find all .git directories and process their parent directories
# -prune prevents find from descending into .git directories
# -print0 and read -d handle special characters in paths
while IFS= read -r -d $'\0' gitdir; do
    repo_dir="$(dirname "$gitdir")"
    repo_name="$(basename "$repo_dir")"
    info_msg "\nProcessing Git repository: $repo_name ($repo_dir)"

    repo_failed=false # Flag for failures within this specific repo

    if [[ "${OPERATIONS[status]}" = true ]]; then
        check_status "$repo_dir"
        # Status doesn't stop other operations
    fi

    if [[ "${OPERATIONS[fetch]}" = true ]]; then
        if ! fetch_changes "$repo_dir"; then
            repo_failed=true
            # Decide if pull should be skipped if fetch fails. Yes.
            info_msg "Skipping pull for $repo_name due to fetch failure."
        elif [[ "${OPERATIONS[pull]}" = true ]]; then
            # Only pull if fetch succeeded
            if ! pull_changes "$repo_dir"; then
                repo_failed=true
                 # Decide if stage/commit should be skipped if pull fails. Maybe.
                 # Let's continue for now, user might want to commit local changes anyway.
                 # info_msg "Skipping further operations for $repo_name due to pull failure."
                 # continue # Skip to next repo if pull fails? Optional.
            fi
        fi
    fi

    # Stage operation (only if -t is specified and -c is not, or if -a is specified)
    # Commit operation implicitly includes staging.
     if [[ "${OPERATIONS[stage]}" = true && "${OPERATIONS[commit]}" = false ]]; then
        if ! stage_changes "$repo_dir"; then
            repo_failed=true
        fi
    fi

    # Commit operation (implies staging first)
    if [[ "${OPERATIONS[commit]}" = true ]]; then
        if ! commit_and_push_changes "$repo_dir"; then
             repo_failed=true
        fi
    fi

    if [[ "$repo_failed" = true ]]; then
        EXIT_STATUS=1 # Mark that at least one repo had issues
        info_msg "Finished processing $repo_name ($repo_dir) with errors."
    else
        verbose_msg "Finished processing $repo_name ($repo_dir) successfully."
    fi

done < <(find "$ROOT_DIR" -name .git -type d -prune -print0)


# --- Summary Report ---
# Only print summary if actual operations were performed (not just status)
if [[ "${OPERATIONS[fetch]}" = true || "${OPERATIONS[pull]}" = true || "${OPERATIONS[stage]}" = true || "${OPERATIONS[commit]}" = true ]]; then
    echo -e "\n===== Git Commander Summary ====="

    print_summary_array "Fetch Failed" "${fetch_failed[@]}"
    print_summary_array "Pull Failed" "${pull_failed[@]}"
    print_summary_array "Stage Failed" "${failed_stages[@]}"
    print_summary_array "Commit Failed" "${failed_commits[@]}"
    print_summary_array "Push Failed" "${failed_pushes[@]}"

    print_summary_array "Successful Pushes" "${successful_pushes[@]}"
    # Distinguish no changes for stage vs commit if both ran? Maybe not necessary.
    # Just report the final state relevant to commit.
    if [[ "${OPERATIONS[commit]}" = true ]]; then
         print_summary_array "Repos With No Changes (Commit)" "${no_changes_commit[@]}"
    elif [[ "${OPERATIONS[stage]}" = true ]]; then
         print_summary_array "Repos With No Changes (Stage)" "${no_changes_stage[@]}"
    fi

    # Always print detailed errors if any occurred
    if [[ ${#git_errors[@]} -gt 0 ]]; then
        echo -e "\nDetailed Errors Encountered:"
        for error in "${git_errors[@]}"; do
             echo -e "  ----\n  $error"
        done
        echo -e "  ----"
        EXIT_STATUS=1 # Ensure exit status reflects errors
    fi

    if [[ $EXIT_STATUS -eq 0 ]]; then
        echo -e "\nAll operations completed successfully."
    else
        echo -e "\nSome operations failed. Please review the output above."
    fi
    echo "==============================="
fi

exit $EXIT_STATUS
