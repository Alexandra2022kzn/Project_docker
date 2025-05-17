# Project_docker (Сборка Docker-образа)

В репозитории приложен Dockerfile, на основе которого собирается образ со следующими специализированными программами:
 
- samtools + htslib + libdeflate;
- bcftools; 
- vcftools. 

# Установка

```bash
docker build -t alexihtwws/samtools_image .
docker run -it alexihtwws/samtools_image
```