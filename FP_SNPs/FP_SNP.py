#!/usr/bin/env python3

import pandas as pd
from pysam import FastaFile
import argparse
import logging

logging.basicConfig(level=logging.INFO, filename="FP_SNP_log.log",filemode="w",
                    format="%(asctime)s %(levelname)s %(message)s")

parser = argparse.ArgumentParser(description='Преобразование VCF файла с определением референсного и альтернативного аллеля')
parser.add_argument('--in_file', type=str, required=True, help='Имя входного файла')
parser.add_argument('--out_file', type=str, required=True, help='Имя выходного файла')
parser.add_argument('--chr_dir', type=str, required=True, help='Папка с референсами хромосом')
args = parser.parse_args()

def get_ref(chr, pos):
    fa = FastaFile(f'{args.chr_dir}/{chr}.fa')
    return fa.fetch(chr, pos-1, pos)

def get_alt(row):
    if row["REF"] == row["allele1"]:
        return row["allele2"]
    elif row["REF"] == row["allele2"]:
        return row["allele1"]
    else:
        return "N"

try:
    logging.info("Загрузка входного файла...")
    with open(args.in_file, 'r') as file:
        first_line = file.readline().rstrip('\n')
        if not first_line:
            logging.error("ValueError : Файл пустой",exc_info=True)
            raise ValueError("Файл пустой")
        if first_line != '#CHROM\tPOS\tID\tallele1\tallele2':
            logging.error("ValueError : Неверный формат файла",exc_info=True)
            raise ValueError("Неверный формат файла")
        
        data = pd.read_csv(args.in_file, sep='\t')
        
        logging.info("Получение референсных аллелей...")
        data['REF'] = data.apply(lambda row: get_ref(row["#CHROM"], row["POS"]), axis=1)
        logging.info(f"Референсные аллели получены. Уникальные значения: {data['REF'].unique()}")
        
        logging.info("Определение альтернативных аллелей...")
        data["ALT"] = data.apply(get_alt, axis=1)

        data.drop(columns=['allele1' ,'allele2'], inplace = True)
        logging.info(f"Распределение полученных аллелей: {data['ALT'].value_counts()}")
        data.to_csv(args.out_file, index=False, sep='\t')
        logging.info("Конец обработки.")

except FileNotFoundError:
    logging.error("FileNotFoundError : Файл отсутствует",exc_info=True)
    print('Файл отсутствует')
