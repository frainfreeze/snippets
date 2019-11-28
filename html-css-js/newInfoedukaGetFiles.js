// log into new infoeduka,
// go to courses and select subject.
// downloads file every 3 seconds (3e3) by clicking on `a` got from HTMLcollection
function doSetTimeout(e){setTimeout(function(){document.getElementsByClassName("ng-binding ng-scope")[e].click()},3e3*e)}for(var i=0;i<document.getElementsByClassName("ng-binding ng-scope").length;++i)doSetTimeout(i);
