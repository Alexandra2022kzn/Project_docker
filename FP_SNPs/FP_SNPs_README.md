# Определение альтернативного и референсного аллеля

В папке `./FP_SNPs`  содержатся следующие файлы:
- `FP_SNP.py` — скрипт для преобразования файла из формата 
`«#CHROM<TAB>POS<TAB>ID<TAB>allele1<TAB>allele2` в формат `«#CHROM<TAB>POS<TAB>ID<TAB>REF<TAB>ALT»`, тем самым выявляя, какой из двух аллелей («allele1», «allele2») является референсным, а какой – альтернативным.
- `FP_SNPs.txt` — сырой файл из GRAF
- `FP_SNPs_10k_GB38_twoAllelsFormat.tsv` — предварительно преобразованный файл из GRAF
- `FP_SNPs_converted.tsv` — обработанный файл с указанием референсного и альтернативного аллеля. В случае несовпадения референского ни с одним из аллелей стоит N
- `FP_SNP_log.log` - файл, содержащий временнЫе метки и логи по ходу выполнения скрипта

## Часть 1: предобработка файла из архива программы GRAF версии 2.4 с официального сайта: https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/Software.cgi.

Преобразование файла FP_SNPs.txt, чтобы формат файла стал максимально похож по формату на VCF и пригоден для популяционных исследований:  
- удалены координаты по GRCh37; 
- изменен порядок колонок; 
- добавлены префиксы chr и rs; 
- удалены варианты с X-хромосомы (23); 
- результат записан в новый промежуточный файл FP_SNPs_10k_GB38_twoAllelsFormat.tsv. 

```bash
awk '{print $1,$2,$4,$5,$6}' FP_SNPs.txt | \
sed -e '1s/chromosome/#CHROM/' -e '1s/GB38_position/POS/' -e '1s/rs#/ID/' | \
awk ' { t = $1; $1 = $2; $2 = $3; $3 = t; print; } ' OFS=$'\t' | \
awk 'NR == 1 {print $0} NR>1{$1="chr"$1; $3="rs"$3; print $0}' OFS=$'\t' | \
awk '$1 != "chr23" { print }' > FP_SNPs_10k_GB38_twoAllelsFormat.tsv
```

## Часть 2: создание .fa файлов и их индексирование для основных хромосом

```bash
# распаковка архива с геномом
tar -xvzf GRCh38.d1.vd1.fa.tar.gz
rm GRCh38.d1.vd1.fa.tar.gz

# разделение файла с референсным геномом на отдельные, соответствующие основным хромосомам 
# использовался код с сайта: https://crashcourse.housegordon.org/split-fasta-files.html
awk '/^>/ { if ($1 ~ /_/) exit
	    gsub(">","",$1)
            FILE=$1 ".fa"
            print ">" $1 >> FILE
            next}
          { print >> FILE }' GRCh38.d1.vd1.fa

# индексирование
for f in *.fa; do
    samtools faidx "$f"
done
```

## Часть 3: Запуск скрипта в ранее созданном образе

Сначала создаем образ и запускаем его в интерактивном режиме с монтированием папки с реферансами хромосом

```bash
docker build -t alexihtwws/samtools_image .
docker run -it -v "/mnt/data/ref/GRCh38.d1.vd1_mainChr/sepChrs/:/ref/GRCh38.d1.vd1_mainChr/sepChrs/" alexihtwws/samtools_image
```

Далее запускаем скрипт
```bash
cd /fp_snp
python3 FP_SNP.py --in_file FP_SNPs_10k_GB38_twoAllelsFormat.tsv --out_file FP_SNPs_converted.tsv --chr_dir /ref/GRCh38.d1.vd1_mainChr/sepChrs/
```

Обобщенные результаты можно посмотреть в `.log` файле, в данном случае мы видим следующий результат:

```
T    2524
A    2503
G    2487
C    2477
N       9
```

Число N показывает количество аллелей, в которых не получилось определить референсный и альтернативный, так как ни один из них не совпал с референсом. 
Числа возле других нуклеотидов показывают их число. В данном случае T:A:G:C = 2524:2503:2487:2477