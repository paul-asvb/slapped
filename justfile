default:
    @just --list

# Build the Docker builder image
image:
    docker build -t slapped-builder .

# Build for Linux
linux: image
    mkdir -p build/linux
    @echo "Building Linux..."
    docker run --rm -v "{{justfile_directory()}}/build:/app/build" slapped-builder

# Build for Web (HTML5)
web: image
    mkdir -p build/web
    @echo "Building Web..."
    docker run --rm -v "{{justfile_directory()}}/build:/app/build" slapped-builder godot --headless --export-release "HTML5" build/web/index.html

# Serve the Web build locally
serve-web: web
    @echo "Serving Web build at http://localhost:8000"
    docker run --rm -p 8000:8000 -v "{{justfile_directory()}}/build/web:/web" python:3-alpine python -m http.server 8000 --directory /web

# Clean build directory
clean:
    rm -rf build/
