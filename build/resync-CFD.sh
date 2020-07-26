#!/bin/bash
cd ${0%/*}/.. || exit 1    # Run from hyStrath directory

set -e

userName=`whoami`

currentDir=`pwd`
sendingDir="$WM_PROJECT_USER_DIR"

nProcs=1
if [ $# -ne 0 ]
  then nProcs=$1;
fi


# synchronize folders and compile new libraries -------------------------------
rsync -rtvuc $currentDir/src/thermophysicalModels/strath/ $sendingDir/src/thermophysicalModels/strath/
cd $sendingDir/src/thermophysicalModels/strath/
./Allwmake -j$nProcs

rsync -rtvuc $currentDir/src/TurbulenceModels/ $sendingDir/src/TurbulenceModels/
cd $sendingDir/src/TurbulenceModels/
./Allwmake -j$nProcs

cd $sendingDir/src/thermophysicalModels/strath/
./AllwmakeBis -j$nProcs

rsync -rtvuc $currentDir/src/hTCModels/ $sendingDir/src/hTCModels/
cd $sendingDir/src/hTCModels
wmake -j$nProcs libso

rsync -rtvuc $currentDir/src/finiteVolume/ $sendingDir/src/finiteVolume/
cd $sendingDir/src/finiteVolume
wmake -j$nProcs libso

rsync -rtvuc $currentDir/src/functionObjects/forces $sendingDir/src/functionObjects/forces
rsync -rtvuc $currentDir/src/functionObjects/field-cfdStrath $sendingDir/src/functionObjects/field-cfdStrath
cd $sendingDir/src/functionObjects
./Allwmake-cfdStrath -j$nProcs

rsync -rtvuc $currentDir/src/fvOptions/ $sendingDir/src/fvOptions/
cd $sendingDir/src/fvOptions
wmake -j$nProcs libso


# compile new executables ------------------------------------------------------
#---- solvers ----
rsync -rtvuc $currentDir/applications/solvers/compressible/hy2Foam/ $sendingDir/applications/solvers/compressible/hy2Foam/
cd $sendingDir/applications/solvers/compressible/hy2Foam/
./Allwmake -j$nProcs 

#---- utilities ----
rsync -rtvuc $currentDir/applications/utilities/mesh/generation/makeAxialMesh $sendingDir/applications/utilities/mesh/generation/makeAxialMesh
cd $sendingDir/applications/utilities/mesh/generation/makeAxialMesh
wmake -j$nProcs 

rsync -rtvuc $currentDir/applications/utilities/mesh/generation/blockMeshDG $sendingDir/applications/utilities/mesh/generation/blockMeshDG
cd $sendingDir/applications/utilities/mesh/generation/blockMeshDG
./Allwmake -j$nProcs 


# re-set to the initial directory ---------------------------------------------
cd $currentDir

echo "
CFD module $WM_PROJECT_VERSION updated successfully. Hope you'll enjoy it, $userName :)
"
