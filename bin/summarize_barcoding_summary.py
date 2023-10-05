#!/usr/bin/env python3

import argparse
import csv
import json
import os
import sys


def parse_barcode_summary(barcode_summary):
    """
    Parse the barcode summary file and return a dictionary of the barcodes
    and their counts.
    """

    float_fields = [
        'barcode_score',
        'barcode_front_score',
        'barcode_rear_score',
        'barcode_mid_front_score',
        'barcode_mid_rear_score',
    ]
    int_fields = [
        'barcode_front_foundseq_length',
        'barcode_front_begin_index',
        'barcode_rear_foundseq_length',
        'barcode_rear_end_index',
        'barcode_front_total_trimmed',
        'barcode_rear_total_trimmed',
        'barcode_mid_front_end_index',
        'barcode_mid_rear_end_index',
    ]
    with open(barcode_summary, 'r') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            for field in float_fields:
                try:
                    row[field] = float(row[field])
                except ValueError:
                    row[field] = None
            for field in int_fields:
                try:
                    row[field] = int(row[field])
                except ValueError:
                    row[field] = None
            yield(row)


def main(args):
    num_reads = 0
    barcode_front_total_trimmed = 0
    barcode_rear_total_trimmed = 0
    num_mid_barcodes = 0
    for row in parse_barcode_summary(args.barcode_summary):
        num_reads += 1
        barcode_front_total_trimmed += row['barcode_front_total_trimmed']
        barcode_rear_total_trimmed += row['barcode_rear_total_trimmed']
        if row['barcode_mid_front_id'] != 'unclassified' or \
           row['barcode_mid_rear_id'] != 'unclassified':
            num_mid_barcodes += 1

            
    output_fieldnames = [
        'num_reads',
        'barcode_front_total_trimmed',
        'barcode_rear_total_trimmed',
        'num_mid_barcodes',
    ]
        
    output = {
        'num_reads': num_reads,
        'barcode_front_total_trimmed': barcode_front_total_trimmed,
        'barcode_rear_total_trimmed': barcode_rear_total_trimmed,
        'num_mid_barcodes': num_mid_barcodes,
    }
    if args.sample_id:
        output_fieldnames.insert(0, 'sample_id')
        output['sample_id'] = args.sample_id

    writer = csv.DictWriter(sys.stdout, delimiter=',', fieldnames=output_fieldnames)
    writer.writeheader()
    writer.writerow(output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--sample-id', help='sample id')
    parser.add_argument('barcode_summary', help='barcode summary file')
    args = parser.parse_args()
    main(args)
