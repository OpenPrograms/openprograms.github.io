var repos = document.getElementsByName("content");
var repoBackup;

function initBackup() {
    repoBackup = [];
    for(var i=0; i < repos.length; i++) {
        repoBackup.push(repos[i].cloneNode(true));
    }
}

function search(event) {
    if(!repoBackup) {
        initBackup();
    }
    var searchRepos = [];
    var search = document.getElementById("searchbox").value.toLowerCase();
    var parent = document.getElementById("searchbox").parentNode;
    if(search.length < 2) {
        searchRepos = repoBackup;
    } else {
        for(var i=0; i < repoBackup.length; i++) {
            var part = repoBackup[i];
            if(part && part.textContent && part.textContent.toLowerCase().indexOf(search) > 0) {
                searchRepos.push(part);
            }
        }
    }
    while(repos.length > 0) {
        var part = repos[0];
        part.parentNode.removeChild(part);
    }
    for(var i=0; i < searchRepos.length; i++) {
        var part = searchRepos[i];
        parent.appendChild(part.cloneNode(true));
    }
}

function trySearch(event) {
    if (event.keyCode == 13) {
        search(event);
    }
}
