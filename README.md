# snoing-2.0
A singularity recipe for building a SNO+ environment for RAT. 

# To build the container
`sudo singularity build snoing.simg Singularity`

# Instructions on how to use the container with RAT

**To build RAT**:
- Clone RAT from GitHub
- Enter the following command, filling in the path to RAT:

`singularity run --app build-rat -B path/to/rat:/rat snoing.simg`
- RAT is now ready to use!

**To exit the container**:

`exit`

**To update RAT**:

`git fetch && git merge`
- Then, follow the instructions above to rebuild RAT

**To run RAT**:
- Enter the following command, filling in the path to RAT:

`singularity shell -B path/to/rat:/rat snoing.simg`

- It is important to mount your rat dir to /rat as the build scripts look there for it!
- RAT is primed, now you can navigate to /rat to run things in the repository. To use other directories as well, see below.

**To read/write files from directories outside of RAT/home**:
- Add additional bind mounts to your singularity shell command
- Example:
`singularity run --app build-rat -B path/to/rat:/rat,other/path:/stuff snoing.simg`
- Now in the container, you have access to other/path by going to /stuff

**To use a specific branch of RAT**:
- Ensure you git checkout to the branch OUTSIDE the container to avoid issues, then run RAT like above
