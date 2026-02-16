# Sequential 2.6.0 (2024-09-07).

Sequential is an image and comic viewer for macOS. This is my personal fork of
the project where I will rewrite the app in Swift and modernize for contemporary
macOS. I expect to work on it sporadically as I have a full time job.


## Source code

The modernized Sequential source code is at <https://github.com/chuchusoft/Sequential>.

The original Sequential source code is at <https://github.com/btrask/Sequential>.





## Building instructions

- decompress the source archive into a folder
  - dependencies are included in the source archive
- open the Sequential folder inside the chosen folder
- open the Sequential.xcodeproj project in Xcode
- select the Sequential build scheme
- use the Product -> Build command





## Distribution instructions

- update the History file

- to create the source backup archive:

% cd ~/folder_containing_sequential_sources
% tar -c -v -J -H -f Sequential.src.2021-08-04.15.27.00.tar.xz --exclude=xcuserdata --exclude=.DS_Store --exclude=.git  --exclude=.gitignore --exclude=.gitattributes --exclude=Sequential/docs --exclude=XADMaster/Windows Sequential XADMaster UniversalDetector

- to distribute the built app:

[1] select Product -> Archive in Xcode then copy the archive to a staging folder, eg,
    ~/Sequential_staging

[2] move the .app bundle to the staging folder:

% mv ~/Sequential_staging/Sequential\ 2021-08-04\ 15.27.00.xcarchive/Products/Applications ~/Sequential_staging

[3] copy the "HOWTO remove the Sequential application from quarantine.rtfd" and
    "Remove quarantine attribute.applescript" files from the distribution folder
    (inside the "Sequential" source folder) to the staging folder

[4] remove Finder .DS_Store files:

% find ~/Sequential_staging -name .DS_Store -exec rm -- {} +

[5] rename the staging folder to include the release date/time:

% mv ~/Sequential_staging ~/Sequential\ 2021-08-04\ 15.27.00

[6] create an archive of the renamed staging folder:

% tar -c -v -J -H -f ~/Sequential.app.2021-08-04.15.27.00.tar.xz ~/Sequential\ 2021-08-04\ 15.27.00
 
[7] upload or distribute the .tar.xz files (app and src)
