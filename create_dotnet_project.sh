#!/bin/bash
cd ..

DEFAULT_DEVELOPMENT_ROOT_PATH=~/Dev


clear_and_log()
{
    clear
    echo "=================================== ${1} ==================================="
    sleep 1
}

echo "What's the name of the new project?"
read -r FILENAME

echo "Where will it be created? ===== PARENT FOLDER ====="
read -r PARENT_FOLDER_NAME

echo "Do you have a development folder? If not leave it blank. DEFAULT: folder named as 'Dev'"
read -r DEVELOPMENT_ROOT_PATH

if [[ ! -z "$DEVELOPMENT_ROOT_PATH" ]]
    then DEFAULT_DEVELOPMENT_ROOT_PATH=$DEVELOPMENT_ROOT_PATH
fi

UPPER_FILENAME="${FILENAME^}"

if [ -d !DEFAULT_DEVELOPMENT_ROOT_PATH ]
    then mkdir "${DEFAULT_DEVELOPMENT_ROOT_PATH}"
fi

cd "${DEFAULT_DEVELOPMENT_ROOT_PATH}" || exit

if [ -d !PARENT_FOLDER_NAME ]
    then mkdir "${PARENT_FOLDER_NAME}"
fi

cd "${DEFAULT_DEVELOPMENT_ROOT_PATH}/${PARENT_FOLDER_NAME}" || exit

mkdir -p "${UPPER_FILENAME}"
cd "${UPPER_FILENAME}"|| exit

clear_and_log "CREATING SRC FOLDER"
mkdir -p "Src"
cd "Src" || exit

clear_and_log "CREATING DOTNET PROJECT BASED ON DDD"
dotnet new classlib --name "${UPPER_FILENAME}".Application
dotnet new classlib --name "${UPPER_FILENAME}".Domain
dotnet new classlib --name "${UPPER_FILENAME}".Infra
dotnet new webapi --name "${UPPER_FILENAME}".Web

clear_and_log "MAKING REFERENCES"
dotnet add ./"${UPPER_FILENAME}".Infra/"${UPPER_FILENAME}".Infra.csproj reference ./"${UPPER_FILENAME}".Domain/"${UPPER_FILENAME}".Domain.csproj
dotnet add ./"${UPPER_FILENAME}".Application/"${UPPER_FILENAME}".Application.csproj reference ./"${UPPER_FILENAME}".Domain/"${UPPER_FILENAME}".Domain.csproj
dotnet add ./"${UPPER_FILENAME}".Web/"${UPPER_FILENAME}".Web.csproj reference ./"${UPPER_FILENAME}".Domain/"${UPPER_FILENAME}".Domain.csproj
dotnet add ./"${UPPER_FILENAME}".Web/"${UPPER_FILENAME}".Web.csproj reference ./"${UPPER_FILENAME}".Application/"${UPPER_FILENAME}".Application.csproj


clear_and_log "CREATING FOLDERS IN APPLICATION LAYER AND INSTALLING LIBS"
cd "${UPPER_FILENAME}".Application || exit

dotnet add package Microsoft.AspNetCore
dotnet add package Microsoft.AspNetCore.Mvc

mkdir -p "Controllers"

cd ..
cd "${UPPER_FILENAME}".Infra || exit

clear_and_log "CREATING FOLDERS IN INFRA LAYER AND INSTALLING LIBS"

dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.EntityFrameworkCore.SqlServer

mkdir -p "Context"
mkdir -p "Mappings"
mkdir -p "Repositories"

cd ..
cd "${UPPER_FILENAME}".Domain || exit

clear_and_log "CREATING FOLDERS IN DOMAIN LAYER AND INSTALLING LIBS"

mkdir -p "Interfaces"
mkdir -p "Models"
mkdir -p "Services"
mkdir -p "ValueObjects"

cd ..
cd "${UPPER_FILENAME}".Web || exit

clear_and_log "CREATING FOLDERS IN WEB LAYER AND INSTALLING LIBS"

dotnet add package Microsoft.EntityFrameworkCore.Design
rm -rf "Controllers" "WeatherForecast.cs"

clear_and_log "CREATING TESTS FOLDER"
cd ../.. || exit
mkdir -p "Tests" && cd "Tests" || exit
dotnet new xUnit --name UnitTests
cd "UnitTests" && mkdir -p "Services"|| exit


clear_and_log "CREATING .GITIGNORE FILE AND DOCKERFILE"
cd ../..
dotnet new gitignore
touch "${DEFAULT_DEVELOPMENT_ROOT_PATH}"/"${PARENT_FOLDER_NAME}"/"${PROJECT_NAME}"/Dockerfile

DOCKERFILE_GENERATOR_PATH=$(find "${DEFAULT_DEVELOPMENT_ROOT_PATH}" -name "create_dotnet_dockerfile.sh" -print)

source "${DOCKERFILE_GENERATOR_PATH}" "${DEFAULT_DEVELOPMENT_ROOT_PATH}" "${PARENT_FOLDER_NAME}" "${UPPER_FILENAME}" || exit

clear_and_log "CREATING SLN FILE AND ADDING CSPROJS FILES TO SOLUTION"
dotnet new sln 
dotnet sln add ./Src/"${UPPER_FILENAME}".Domain/"${UPPER_FILENAME}".Domain.csproj
dotnet sln add ./Src/"${UPPER_FILENAME}".Application/"${UPPER_FILENAME}".Application.csproj
dotnet sln add ./Src/"${UPPER_FILENAME}".Infra/"${UPPER_FILENAME}".Infra.csproj
dotnet sln add ./Src/"${UPPER_FILENAME}".Web/"${UPPER_FILENAME}".Web.csproj
