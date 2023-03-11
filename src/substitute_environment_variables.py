import os
import sys
import getopt
import jinja2


def load_template_from_path(path: str):
    path, file_name = os.path.split(path)
    return jinja2.Environment(
        loader=jinja2.FileSystemLoader(path or "./")
    ).get_template(file_name)


def build_deployment_manifest_from_path(template, path):
    content = template.render(os.environ)

    with open(path, mode="w", encoding="utf-8") as f:
        f.write(content)


if __name__ == "__main__":
    argv = sys.argv[1:]
    options, args = getopt.getopt(sys.argv[1:], "i:o", ["input-file=", "output-file="])

    for opt, arg in options:
        if opt in ("-i", "--input-file"):
            input_file_path = arg
        elif opt in ("-o", "--output-file"):
            output_file_path = arg

    template = load_template_from_path(input_file_path)
    build_deployment_manifest_from_path(template, output_file_path)
