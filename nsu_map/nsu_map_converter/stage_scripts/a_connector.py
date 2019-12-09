import json

__CONNECTIONS = {
    "new": [
        # ("000000", "100000"),
        # ("100001", "200000"),
        # ("200000", "300000"),
        # ("300000", "400000"),
        # ("400000", "500000"),
        #
        # ("000301", "100301"),
        # ("000300", "100300"),
        # ("100302", "200303"),
        # ("100303", "200302"),
        # ("100301", "200301"),
        # ("100300", "200300"),
        # ("200300", "300300"),
        # ("200301", "300301"),
        # ("200302", "300302"),
        # ("200303", "300303"),
        # ("300300", "400301"),
        # ("300301", "400300"),
        # ("300302", "400303"),
        # ("300303", "400302"),
        # ("400301", "500300"),
        # ("400300", "500301"),
        # ("400303", "500302"),
        # ("400302", "500303"),
    ],
    "old": [
        # ("s01", "s11"),
        # ("s10", "s20"),
        # ("s11", "s21"),
        # ("s12", "s22"),
        # ("s20", "s30"),
        # ("s21", "s31"),
        # ("s22", "s32"),
        # ("s30", "s40"),
        # ("s31", "s41"),
        # ("s32", "s42"),
        # ("s40", "s50"),
        # ("s41", "s51"),
        # ("s42", "s52"),
        # ("s52", "s62"),
        # ("100300_l", "200302_l"),
        # ("100301_l", "200301_l"),
        # ("100302_l", "200300_l"),
        # ("200302_l", "300300_l"),
        # ("200301_l", "300301_l"),
        # ("200300_l", "300302_l"),
        # ("300300_l", "400300_l"),
        # ("300301_l", "400301_l"),
        # ("300302_l", "400302_l"),
        # ("400300_l", "500300_l"),
        # ("400301_l", "500301_l"),
        # ("400302_l", "500302_l"),
    ]
}


def run(file_name: str):
    with open("jsons/" + file_name + ".json") as roomsFile:
        points = json.load(roomsFile)

    connections_map = {}

    def add_connection(from_, to_):
        neighbors = connections_map.setdefault(from_, [])

        if to_ not in neighbors:
            neighbors.append(to_)

        connections_map[from_] = neighbors

    for connection in __CONNECTIONS[file_name]:
        add_connection(connection[0], connection[1])
        add_connection(connection[1], connection[0])

    for start in connections_map:
        if len(start) < 4 or start[3] != "3":
            continue

        added = True

        while added:
            neighbors_1 = connections_map[start]

            added = False

            for neighbor_1 in neighbors_1:
                neighbors_2 = connections_map[neighbor_1]

                for neighbor_2 in neighbors_2:
                    if neighbor_2 not in neighbors_1 and neighbor_2 != start:
                        neighbors_1.append(neighbor_2)

                        added = True

    for point in points:
        point_id = point["id"]

        if point_id not in connections_map:
            continue

        connections = connections_map[point_id]
        neighbors = point["neighbors"].split(" ")

        for connection in connections:
            if connection not in neighbors:
                neighbors.append(connection)

        point["neighbors"] = " ".join(neighbors)

    with open("jsons/" + file_name + "_connected.json", "w") as merged:
        json.dump(points, merged, indent=4)
