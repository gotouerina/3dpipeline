# 3dpipeline
Pipeline for 3dgenome analysis

先对参考基因组建索引

    chromap -i -r ref.fasta -o index

再比对

    chromap --preset hic -r ref.fasta -x index R1.fq.gz -2 R2.fq.gz -t 50 -o aln.pairs  #RAM 20G

输出的是pair格式，pair格式再load进cooler, cooler一行pip就能装，如果环境冲突了conda弄一个新的python环境

先需要一个chrome.size文件，这个很好做

    samtools faidx ref.fasta | cuf -f 1,2 > ref.chrome.size

    bgzip aln.pairs.gz 

    pairix aln.pairs.gz #生成一个后缀为px2的索引文件

    cooler cload pairix ref.chrome.size:50000 aln.pairs.gz ref.cool -p 50#这一步需要索引，需要用pairix建,没有索引可以用 cooler cload pairs
   

下游的分析考虑用hicexplorer做一下， hicexplore应该可以同时做AB区室， loop， TAD这三大件。hicexplorer读取的事h5和cool格式，cool格式转H5会出现一点问题，所以暂时不转

继续做一些下游处理

    cooler balance ref.cool #标准化
    cooler zoomify ref.cool #生成不同窗口大小
    cooler ls cahirinus.mcool #查看含有的分辨率情况

最后做个性化分析，前面这几步可通过上面写的3dGenomics.pl脚本实现

#    一、A/B区室
    hicPCA -m ref.cool::/resolutions/50000 --outFileName pca1.bw pca2.bw --format bigwig --pearsonMatrix pearson.h5
这里第一主成分是区室，需要根据基因密度或者GC校正一下符号

#    二、找TAD
    hicFindTADs -m ref.cool::/resolutions/50000 --outPrefix hic_corrected --numberOfProcessors 16 --correctForMultipleTesting fdr

#    三、找loop
    hicDetectLoops -m ref.cool::/resolutions/50000 -o loops.bedgraph --maxLoopDistance 2000000 --windowSize 10 --peakWidth 6 --pValuePreselection 0.05 --pValue 0.05




        
     

