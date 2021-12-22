FROM bhojpur/platform-full:latest

USER bhojpur

# Install Microsoft .NET SDK (LTS channel)
# Source: https://docs.microsoft.com/dotnet/core/install/linux-scripted-manual#scripted-install
RUN mkdir -p /home/bhojpur/dotnet && curl -fsSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --install-dir /home/bhojpur/dotnet
ENV DOTNET_ROOT=/home/bhojpur/dotnet
ENV PATH=$PATH:/home/bhojpur/dotnet
