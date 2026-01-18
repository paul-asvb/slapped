FROM barichello/godot-ci:4.3

WORKDIR /app
COPY . .

# Create build directory
RUN mkdir -p build/linux

# Export for Linux
# "Linux" matches the preset name in export_presets.cfg
CMD ["godot", "--headless", "--export-release", "Linux", "build/linux/slapped.x86_64"]
