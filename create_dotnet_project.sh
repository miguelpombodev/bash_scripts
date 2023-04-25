#!/bin/bash
cd ..

clear_and_log()
{
    clear
    echo "=================================== ${1} ==================================="
    sleep 1
}

echo "What's the name of the new project?"
read -r FILENAME

UPPER_FILENAME="${FILENAME^}"

mkdir -p "${UPPER_FILENAME}"
cd ${UPPER_FILENAME}


clear_and_log "CREATING DOTNET PROJECT BASED ON DDD"
dotnet new classlib --name ${UPPER_FILENAME}.Application
dotnet new classlib --name ${UPPER_FILENAME}.Domain
dotnet new classlib --name ${UPPER_FILENAME}.Infra
dotnet new webapi --name ${UPPER_FILENAME}.Web
dotnet new xUnit --name ${UPPER_FILENAME}.Tests

clear_and_log "CREATING SLN FILE"
dotnet new sln

clear_and_log "ADDING CSPROJS FILES TO SOLUTION"
dotnet sln add ./${UPPER_FILENAME}.Domain/${UPPER_FILENAME}.Domain.csproj
dotnet sln add ./${UPPER_FILENAME}.Application/${UPPER_FILENAME}.Application.csproj
dotnet sln add ./${UPPER_FILENAME}.Infra/${UPPER_FILENAME}.Infra.csproj
dotnet sln add ./${UPPER_FILENAME}.Web/${UPPER_FILENAME}.Web.csproj

clear_and_log "MAKING REFERENCES"
dotnet add ./${UPPER_FILENAME}.Infra/${UPPER_FILENAME}.Infra.csproj reference ./${UPPER_FILENAME}.Domain/${UPPER_FILENAME}.Domain.csproj
dotnet add ./${UPPER_FILENAME}.Application/${UPPER_FILENAME}.Application.csproj reference ./${UPPER_FILENAME}.Domain/${UPPER_FILENAME}.Domain.csproj
dotnet add ./${UPPER_FILENAME}.Web/${UPPER_FILENAME}.Web.csproj reference ./${UPPER_FILENAME}.Domain/${UPPER_FILENAME}.Domain.csproj
dotnet add ./${UPPER_FILENAME}.Web/${UPPER_FILENAME}.Web.csproj reference ./${UPPER_FILENAME}.Application/${UPPER_FILENAME}.Application.csproj


clear_and_log "CREATING FOLDERS IN APPLICATION LAYER AND INSTALLING LIBS"
cd ${UPPER_FILENAME}.Application

dotnet add package Microsoft.AspNetCore
dotnet add package Microsoft.AspNetCore.Mvc

mkdir -p "Controllers"

cd ..
cd ${UPPER_FILENAME}.Infra

clear_and_log "CREATING FOLDERS IN INFRA LAYER AND INSTALLING LIBS"

dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.EntityFrameworkCore.SqlServer

mkdir -p "Context"
mkdir -p "Mappings"
mkdir -p "Repositories"

cd ..
cd ${UPPER_FILENAME}.Domain

clear_and_log "CREATING FOLDERS IN DOMAIN LAYER AND INSTALLING LIBS"

mkdir -p "Interfaces"
mkdir -p "Models"
mkdir -p "Services"
mkdir -p "ValueObjects"

cd ..
cd ${UPPER_FILENAME}.Web

clear_and_log "CREATING FOLDERS IN WEB LAYER AND INSTALLING LIBS"

dotnet add package Microsoft.EntityFrameworkCore.Design
rm -rf "Controllers" "WeatherForecast.cs"

clear_and_log "CREATING .GITIGNORE FILE AND DOCKERFILE"
cd ..
dotnet new gitignore
touch Dockerfile
