#!/usr/bin/env python3

import pandas as pd
from pysam import FastaFile
import argparse
import logging

logging.basicConfig(level=logging.INFO, filename="FP_SNP_log.log",filemode="w",
                    format="%(asctime)s %(levelname)s %(message)s")
logging.info("An INFO")

parser = argparse.ArgumentParser(description='Преобразование VCF файла с определением референсного и альтернативного аллеля')
parser.add_argument('--in_file', type=str, required=True, help='Имя входного файла')
parser.add_argument('--out_file', type=str, required=True, help='Имя выходного файла')
args = parser.parse_args()

def get_ref(chr, pos):
    fa = FastaFile(f'sepChrs/{chr}.fa')
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
            raise ValueError("Файл пустой")
        if first_line != '#CHROM\tPOS\tID\tallele1\tallele2':
            raise ValueError("Неверный формат файла")
        
        data = pd.read_csv(args.in_file, sep='\t')
        data = data[:10]
        
        logging.info("Получение референсных аллелей...")
        data['REF'] = data.apply(lambda row: get_ref(row["#CHROM"], row["POS"]), axis=1)
        data['REF'].unique() # можно использовать для проверки, что нет никаких лишних букв/символов

        logging.info("Определение альтернативных аллелей...")
        data["ALT"] = data.apply(get_alt, axis=1)

        data.drop(columns=['allele1' ,'allele2'], inplace = True)
        print(data['ALT'].value_counts())
        data.to_csv(args.out_file, index=False, sep='\t')
        logging.info("Конец обработки.")

except FileNotFoundError:
    print('Файл отсутствует')

