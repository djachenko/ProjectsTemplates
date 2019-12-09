import json
from typing import List


def run(file_names: List[str]):
    graph = []
    points = {}

    for file_name in file_names:
        with open("jsons/" + file_name + "_converted.json") as roomsFile:
            mapping = json.load(roomsFile)

            graph += mapping["graph"]
            points.update(mapping)

    points.pop("graph")

    result = {
        "points": points,
        "graph": graph
    }

    with open("jsons/final.json", "w") as final_file:
        json.dump(result, final_file, indent=4)
