#!/bin/bash

DEFAULT_DEVELOPMENT_ROOT_PATH=$1
PARENT_FOLDER_NAME=$2
PROJECT_NAME=$3

echo "
# .NET Core SDK
FROM mcr.microsoft.com/dotnet/core/sdk:6.0-alpine AS build

# Sets the working directory
WORKDIR /app

# Copy Projects
#COPY *.sln .
COPY Src/${PROJECT_NAME}.Application/${PROJECT_NAME}.Application.csproj ./Src/${PROJECT_NAME}.Application/
COPY Src/${PROJECT_NAME}.Domain/${PROJECT_NAME}.Domain.csproj ./Src/${PROJECT_NAME}.Domain/
COPY Src/${PROJECT_NAME}.Infra/${PROJECT_NAME}.Infra.csproj ./Src/${PROJECT_NAME}.Infra/
COPY Src/${PROJECT_NAME}.Web/${PROJECT_NAME}.Web.csproj ./Src/${PROJECT_NAME}.Web/

# .NET Core Restore
RUN dotnet restore ./Src/${PROJECT_NAME}.Web/${PROJECT_NAME}.Web.csproj

# Copy All Files
COPY Src ./Src

# .NET Core Build and Publish
RUN dotnet publish ./Src/${PROJECT_NAME}.Web/${PROJECT_NAME}.Web.csproj -c Release -o /publish

# ASP.NET Core Runtime
FROM mcr.microsoft.com/dotnet/core/aspnet:6.0-alpine AS runtime
WORKDIR /app
COPY --from=build /publish ./

# Expose ports
EXPOSE 80
EXPOSE 443

# Setup your variables before running.
ARG MyEnv
ENV ASPNETCORE_ENVIRONMENT "\$MyEnv"

ENTRYPOINT ["dotnet", ""${PROJECT_NAME}".Web.dll"]
" >> "${DEFAULT_DEVELOPMENT_ROOT_PATH}"/"${PARENT_FOLDER_NAME}"/"${PROJECT_NAME}"/Dockerfile