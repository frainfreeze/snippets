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
VERSION="1.0.0"
SCRIPT_NAME="Git Commander"
SCRIPT_DESCRIPTION="A tool to manage multiple git repositories"
COMMIT_MESSAGE="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
COMMIT_MESSAGE_SUMMARY_APP="llmdiffsummary"

# Save the starting directory
start_dir=$(pwd)

# Initialize arrays to store results
successful_pushes=()
no_changes=()
not_git_repos=()
failed_pushes=()
fetch_failed=()
pull_failed=()
VERBOSE=false

# Version function
show_version() {
    echo "$SCRIPT_NAME version $VERSION"
    echo "$SCRIPT_DESCRIPTION"
    echo
}

# Help function
show_help() {
    show_version
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
    echo "  -s, --status   Show status of all git repositories"
    echo "  -f, --fetch    Fetch changes from remote repositories"
    echo "  -p, --pull     Pull changes from remote repositories"
    echo "  -c, --commit   Commit and push changes (default behavior)"
    echo "  -a, --all      Perform fetch, pull, commit and push operations"
    echo "  -t, --stage    Stage all changes without committing"
    echo "  --verbose      Show detailed output"
    echo
    echo "Examples:"
    echo "  $0 --status    # Show status of all repositories"
    echo "  $0 --fetch     # Only fetch changes"
    echo "  $0 --all       # Perform all operations"
    echo "  $0 --stage     # Stage all changes"
    echo
}

# Function to check git status
check_status() {
    local dir="$1"
    local status_output
    status_output=$(git -C "$dir" status -s)
    if [ -z "$status_output" ]; then
        echo "Status for repository $dir: /"
    else
        echo "Status for repository $dir:"
        echo "$status_output"
    fi
}

# Function to fetch changes
fetch_changes() {
    local dir="$1"
    [[ "$VERBOSE" = true ]] && echo "Fetching changes in: $dir"
    if git -C "$dir" fetch --all 2>/dev/null; then
        [[ "$VERBOSE" = true ]] && echo "✅ Successfully fetched changes in $dir"
    else
        echo "❗Failed to fetch changes in $dir"
        fetch_failed+=("$dir")
    fi
}

# Function to pull changes
pull_changes() {
    local dir="$1"
    echo "Pulling changes in: $dir"
    if git -C "$dir" pull 2>/dev/null; then
        echo "✅ Successfully pulled changes in $dir"
    else
        echo "❗Failed to pull changes in $dir"
        pull_failed+=("$dir")
    fi
}

# Function to stage changes
stage_changes() {
    local dir="$1"
    [[ "$VERBOSE" = true ]] && echo "Staging changes in: $dir"
    
    # Check for untracked files
    local has_untracked=false
    if [ -n "$(git -C "$dir" ls-files --others --exclude-standard)" ]; then
        has_untracked=true
    fi
    
    # Check for modified tracked files
    local has_modifications=false
    if ! git -C "$dir" diff-index --quiet HEAD --; then
        has_modifications=true
    fi
    
    if [ "$has_untracked" = true ] || [ "$has_modifications" = true ]; then
        git -C "$dir" add .
        [[ "$VERBOSE" = true ]] && echo "✅ Changes staged in $dir"
    else
        [[ "$VERBOSE" = true ]] && echo "No changes to stage in $dir"
        no_changes+=("$dir")
    fi
}

# Function to process a git repository
process_git_repo() {
    local dir="$1"
    local operation="$2"
    
    case $operation in
        "status")
            check_status "$dir"
            ;;
        "fetch")
            fetch_changes "$dir"
            ;;
        "pull")
            pull_changes "$dir"
            ;;
        "stage")
            stage_changes "$dir"
            ;;
        "commit")
            # Original commit and push logic
            cd "$dir"
            if ! git diff-index --quiet HEAD --; then
                echo "Changes found in $dir"
                git add .
                
                # Generate commit message. Use summary app if available.
                local message="$COMMIT_MESSAGE"
                if command -v "$COMMIT_MESSAGE_SUMMARY_APP" &> /dev/null; then
                    local summary=$(git diff HEAD | "$COMMIT_MESSAGE_SUMMARY_APP")
                    if [ -n "$summary" ]; then
                        message="$summary"
                    fi
                fi
                
                git commit -m "$message"
                if git push 2>&1; then
                    echo "✅ Changes committed and pushed in $dir"
                    successful_pushes+=("$dir")
                else
                    echo "❗Failed to push changes in $dir"
                    failed_pushes+=("$dir")
                fi
            else
                [[ "$VERBOSE" = true ]] && echo "No changes in $dir"
                no_changes+=("$dir")
            fi
            cd "$start_dir"
            ;;
    esac
}

# Function to recursively find and process git repositories
find_git_repos() {
    local current_dir="$1"
    local operation="$2"
    
    if [ -d "$current_dir/.git" ]; then
        process_git_repo "$current_dir" "$operation"
        return
    fi
    
    for dir in "$current_dir"/*/; do
        if [ -d "$dir" ]; then
            dir=${dir%/}
            if [ -d "$dir/.git" ]; then
                process_git_repo "$dir" "$operation"
            else
                if [ -d "$dir" ] && [ ! -d "$dir/.git" ]; then
                    not_git_repos+=("$dir")
                fi
                find_git_repos "$dir" "$operation"
            fi
        fi
    done
}

# Parse command line arguments
OPERATION="commit"  # default operation

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        -v|--version) show_version; exit 0 ;;
        -s|--status) OPERATION="status" ;;
        -f|--fetch) OPERATION="fetch" ;;
        -p|--pull) OPERATION="pull" ;;
        -c|--commit) OPERATION="commit" ;;
        -t|--stage) OPERATION="stage" ;;
        --verbose) VERBOSE=true ;;
        -a|--all) 
            find_git_repos "." "fetch"
            find_git_repos "." "pull"
            find_git_repos "." "commit"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Execute the selected operation
find_git_repos "." "$OPERATION"

# Print summary report (only for relevant operations)
if [[ "$OPERATION" != "status" ]]; then
    echo -e "\n=== Summary ==="
    
    if [[ "$OPERATION" == "fetch" && ${#fetch_failed[@]} -gt 0 ]]; then
        echo -e "\nFailed fetches: ${#fetch_failed[@]}"
        [[ "$VERBOSE" = true ]] && printf '%s\n' "${fetch_failed[@]}"
    fi
    
    if [[ "$OPERATION" == "pull" && ${#pull_failed[@]} -gt 0 ]]; then
        echo -e "\nFailed pulls: ${#pull_failed[@]}"
        [[ "$VERBOSE" = true ]] && printf '%s\n' "${pull_failed[@]}"
    fi
    
    if [[ "$OPERATION" == "commit" || "$OPERATION" == "stage" ]]; then
        if [[ "$OPERATION" == "commit" ]]; then
            echo -e "\nSuccessful pushes: ${#successful_pushes[@]}"
            [[ "$VERBOSE" = true && ${#successful_pushes[@]} -gt 0 ]] && printf '%s\n' "${successful_pushes[@]}"
            
            if [ ${#failed_pushes[@]} -gt 0 ]; then
                echo -e "\nFailed pushes: ${#failed_pushes[@]}"
                printf '%s\n' "${failed_pushes[@]}"
            fi
        fi
        
        echo -e "\nNo changes: ${#no_changes[@]}"
        [[ "$VERBOSE" = true && ${#no_changes[@]} -gt 0 ]] && printf '%s\n' "${no_changes[@]}"
    fi
    
    [[ "$VERBOSE" = true ]] && {
        echo -e "\nNon-git directories: ${#not_git_repos[@]}"
        [ ${#not_git_repos[@]} -gt 0 ] && printf '%s\n' "${not_git_repos[@]}"
    }
fi
