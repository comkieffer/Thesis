#! /usr/bin/python3

import argparse, re

def parse_record(record):
    regex = r"^\*(?P<record_type>\w*):(?P<record_data>.*)$"
    matches = re.finditer(regex, test_str, re.MULTILINE)

    data_sources = []
    for idx, match in enumerate(matches):
        data_source, data = matches.groups()




def extract_records(data):
    regex = r"(?P<record>.*?)^-"
    matches = re.finditer(regex, test_str, re.MULTILINE | re.DOTALL)
    
    records = []
    for idx, record in enumerate(matches):
        records.append(record)

    return record


def parse_log(input_file, output_folder):

    with open(input_file, 'r') as infile:
        data = infile.read()

    records = extract_records(data)
    for record in records:
        parse_record(record)



if __name__ == '__main__':
    parser = argparse,ArgumentParser()
    parser.add_argument(
        'input_file', type=str, requred=True, help='The input file')
    parser.add_argument(
        '--output-folder', type=str, help='The output folder')

    args = parser.parse_args()

    parse_log(args.input_file, args.output_folder)
