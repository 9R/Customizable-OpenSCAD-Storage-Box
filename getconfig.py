def extract_config_section(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    config_start = None
    config_end = None

    # Search for CONFIGSTART and CONFIGEND
    for idx, line in enumerate(lines):
        if "//CONFIGSTART" in line:
            config_start = idx + 1  # Start after the CONFIGSTART line
        elif "//CONFIGEND" in line:
            config_end = idx
            break

    # Extract the config section
    if config_start is not None and config_end is not None:
        config_section = lines[config_start:config_end]
        return "".join(config_section)
    else:
        return None

# Usage
file_path = "ScadBox.scad"
config = extract_config_section(file_path)
if config:
    print("Config Section:\n", config)
else:
    print("Config section not found.")
