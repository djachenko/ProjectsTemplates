from stage_scripts import a_postfixer, b_converter, c_merger, a_connector, ba_elevators_connector

if __name__ == '__main__':
    file_names = [
        "new",
        "old"
    ]

    for file_name in file_names:
        a_connector.run(file_name)
        a_postfixer.run(file_name, "_n")
        b_converter.run(file_name)

    c_merger.run(file_names)
