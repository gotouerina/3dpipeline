# 3dpipeline
Pipeline for 3dgenome analysis

先对参考基因组建索引

    chromap -i -r ref.fasta -o index

再比对

    chromap --preset hic -r ref.fasta -x index R1.fq.gz -2 R2.fq.gz -t 50 -o aln.pairs

输出的是pair格式，pair格式再load进cooler, cooler一行pip就能装，如果环境冲突了conda弄一个新的python环境

先需要一个chrome.size文件，这个很好做

    samtools faidx ref.fasta | cuf -f 1,2 > ref.chrome.size

    bgzip aln.pairs.gz

    pairix aln.pairs.gz

    cooler cload pairix ref.chrome.size:50000 aln.pairs.gz ref.cool #这一步需要索引，需要用pairix建

标准化

    cooler balance ref.cool

生成不同分辨率的mcool文件

    cooler zoomify ref.cool

这一步可选分辨率

下游的分析考虑用hicexplorer做一下， hicexplore应该可以同时做AB区室， loop， TAD这三大件。hicexplorer读取的事h5格式，所以需要先做一下格式转化

    hicConvertFormat --matrices MATRICES [MATRICES ...] --outFileName
OUTFILENAME [OUTFILENAME ...] --inputFormat
{h5,cool,hic,homer,hicpro,2D-text} --outputFormat
{cool,h5,homer,ginteractions,mcool,hicpro}

把标准化后的cool格式转成h5格式就行，好像cool格式也可以直接读取，不用转，试试看

#一、A/B区室
    hicPCA -m hic_corrected.h5 --outFileName pca1.bw pca2.bw --format bigwig --pearsonMatrix pearson.h5
这里第一主成分是区室，需要根据基因密度或者GC校正一下符号

#二、找TAD
    hicFindTADs -m hic_corrected.h5 --outPrefix hic_corrected --numberOfProcessors 16

#三、找loop
    hicDetectLoops -m matrix.cool -o loops.bedgraph --maxLoopDistance 2000000 --windowSize 10 --peakWidth 6 --pValuePreselection 0.05 --pValue 0.05
