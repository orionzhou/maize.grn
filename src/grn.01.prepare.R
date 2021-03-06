source("functions.R")
gcfg = read_genome_conf()
tm = v3_to_v4()

#{{{ process Y1H results
dirw = file.path(dird, '08_y1h')
fi = file.path(dirw, 'phenolic.xlsx')
ti = read_xlsx(fi, skip=2,
               col_names=c('reg.name','reg.ogid','tgt.ogid','tgt.name')) %>%
    inner_join(tm, by=c('reg.ogid'='ogid')) %>%
    rename(reg.gid=gid, reg.type=type) %>%
    inner_join(tm, by=c('tgt.ogid'='ogid')) %>%
    rename(tgt.gid=gid, tgt.type=type) %>%
    filter(reg.type %in% c('1-to-1','1-to-many')) %>%
    filter(tgt.type %in% c('1-to-1','1-to-many')) %>%
    distinct(reg.gid, tgt.gid, reg.type, tgt.type)
ti %>% count(reg.type, tgt.type)

to = ti %>% select(reg.gid, tgt.gid)
fo = file.path(dirw, '01.y1h.tsv')
write_tsv(to, fo)
#}}}

#{{{ # collect known TF targets
dirw = file.path(dird, '07_known_tf')
#{{{ KN1
tag = 'KN1'
fi = sprintf("%s/raw/%s.tsv", dirw, tag)
ti = read_tsv(fi) %>%
    transmute(ogid = `Gene ID`,
              binding = `High confidence binding loci within 10 kb`,
              fdr_ear = `FDR ear`,
              fdr_tassel = `FDR tassel`,
              fdr_SAM = `FDR sam`,
              fdr_leaf = `FDR leaf homo/wt`,
              fdr_leaf_het = `FDR leaf het/wt`
    ) %>%
    filter(binding == 'yes')

tia = ti %>% filter(fdr_ear < .01) %>% mutate(tag = 'KN1_ear')
tib = ti %>% filter(fdr_tassel < .01) %>% mutate(tag = 'KN1_tassel')
tic = ti %>% filter(fdr_leaf < .01) %>% mutate(tag = 'KN1_leaf')
tid = ti %>% filter(fdr_ear<.01, fdr_tassel<.01, fdr_leaf<.01) %>% mutate(tag = 'KN1_any')
tie = ti %>% filter(fdr_ear<.01 | fdr_tassel<.01 | fdr_leaf<.01) %>% mutate(tag = 'KN1_all')
ti2 = rbind(tia, tib, tic)
ti2 %>% count(tag)

ti3 = ti2 %>% inner_join(tm, by = 'ogid')
ti3 %>% count(type)
ti4 = ti3 %>% filter(type == '1-to-1')
ti4 %>% count(tag)
sum(ti4$gid %in% gcfg$gene$gid)
kn1 = ti4 %>% select(tag, tgt.gid = gid)
kn1 %>% count(tag)
kn1 %>% distinct(tag, tgt.gid) %>% count(tag)
#}}}

#{{{ P1
fi = file.path(dird, "04_tfbs", "P1/00.xlsx")
p1 = read_xlsx(fi) %>%
    select(tgt.gid = 9) %>% mutate(tag = 'P1') %>%
    filter(!is.na(tgt.gid)) %>% select(tag, tgt.gid)
#}}}

#{{{ FEA4
tag = 'FEA4'
fi = sprintf("%s/raw/%s.tsv", dirw, tag)
ti = read_tsv(fi, col_names = F)
ti2 = ti %>%
    transmute(ogid = X1, note = X2, DE = X3) %>%
    filter(DE == 'yes')
ti3 = ti2 %>% inner_join(tm, by = 'ogid')
ti3 %>% count(type)
ti4 = ti3 %>% filter(type == '1-to-1')
sum(ti4$gid %in% gcfg$gene$gid)
fea4 = ti4 %>% mutate(tag=tag) %>% select(tag, tgt.gid = gid)
fea4 %>% count(tag)
#}}}

#{{{ O2
# liftOver 01.v3.coord.bed $genome/B73/chain/AGP_v3_to_v4.bed.gz 02.v4.coord.bed 03.unmapped.bed
# slopBed -i 02.v4.coord.bed -g $genome/B73/15.sizes -b 10000 > 05.flank10k.bed
# intersectBed -a $genome/B73/v37/gene.bed -b 05.flank10k.bed -u > 06.ovlp.gid.bed
#fi = file.path(dirw, "o2/06.ovlp.gid.bed")
#ti = read_tsv(fi, col_names = F, col_types = c('ciic'))
tag = 'O2'
fi = sprintf("%s/raw/%s.tsv", dirw, tag)
ti = read_tsv(fi, col_names = F) %>%
    transmute(ogid = X1)
ti3 = ti %>% inner_join(tm, by = 'ogid')
ti3 %>% count(type)
ti4 = ti3 %>% filter(type == '1-to-1')
sum(ti4$gid %in% gcfg$gene$gid)
o2 = ti4 %>% mutate(tag=tag) %>% select(tag, tgt.gid = gid)
o2 %>% count(tag)
#}}}

#{{{ RA1
tag = 'RA1'
fi = sprintf("%s/raw/%s.tsv", dirw, tag)
ti = read_tsv(fi, col_names = F)
ti2 = ti %>% transmute(ogid = X2, de1 = X5 ,de2 = X7) %>% 
    filter(de1 == 'yes' | de2 == 'yes')
nrow(ti2)
ti3 = ti2 %>% inner_join(tm, by = 'ogid')
ti3 %>% count(type)
ti4 = ti3 %>% filter(type == '1-to-1')
sum(ti4$gid %in% gcfg$gene$gid)
ra1 = ti4 %>% mutate(tag=tag) %>% select(tag, tgt.gid = gid)
ra1 %>% count(tag)
#}}}

#{{{ HDA101
tag = 'HDA101'
fi = sprintf("%s/raw/%s.tsv", dirw, tag)
ti = read_tsv(fi, col_names = F)
ti2 = ti %>% transmute(ogid = X1)
nrow(ti2)
ti3 = ti2 %>% inner_join(tm, by = 'ogid')
ti3 %>% count(type)
ti4 = ti3 %>% filter(type == '1-to-1')
sum(ti4$gid %in% gcfg$gene$gid)
hda101 = ti4 %>% mutate(tag=tag) %>% select(tag, tgt.gid = gid)
hda101 %>% count(tag)
#}}}

#{{{ bZIP22
tag = 'bZIP22'
fi = sprintf("%s/raw/%s.tsv", dirw, tag)
ti = read_tsv(fi, col_names = F)
tfid = ti$X1[1]
ti2 = ti %>% transmute(ogid = X2)
nrow(ti2)
ti3 = ti2 %>% inner_join(tm, by = 'ogid')
ti3 %>% count(type)
ti4 = ti3 %>% filter(type == '1-to-1')
sum(ti4$gid %in% gcfg$gene$gid)
bzip22 = ti4 %>% mutate(tag=tag) %>% select(tag, tgt.gid = gid)
bzip22 %>% count(tag)
#}}}

#{{{ TB1
tag = 'TB1'
fi = sprintf("%s/raw/%s.xlsx", dirw, tag)
ti = read_xlsx(fi, skip=1)
ti2 = ti %>% select(ogid = 1)
ti3 = ti2 %>% inner_join(tm, by = 'ogid')
ti3 %>% count(type)
ti4 = ti3 %>% filter(type == '1-to-1')
sum(ti4$gid %in% gcfg$gene$gid)
tb1 = ti4 %>% mutate(tag=tag) %>% select(tag, tgt.gid = gid)
tb1 %>% count(tag)
#}}}

tf = read_tf_info() %>% distinct(tf, gid) %>% rename(reg.gid=gid)
to = rbind(kn1, p1, fea4, o2, ra1, hda101, bzip22, tb1) %>%
    mutate(tf = str_replace(tag, "_.*$", '')) %>%
    left_join(tf, by='tf') %>% select(tag, reg.gid, tgt.gid)
to %>% count(tag, reg.gid)
fo = file.path(dirw, '10.known.tf.tgts.tsv')
write_tsv(to, fo)
#}}}

#{{{ ## Walley2016 and Huang2018 GRNs
lift_previous_grn <- function(nid, study, tag, tm, dird = '~/projects/maize.grn/data') {
    #{{{
    fi = sprintf("%s/05_previous_grns/%s_%s.txt", dird, study, tag)
    if(study == 'huang')
        ti = read_tsv(fi)[,1:3]
    else
        ti = read_tsv(fi, col_names = F)[,1:3]
    colnames(ti) = c('rid', 'tid', 'score')
    tn = ti %>%
        inner_join(tm, by = c('rid' = 'ogid')) %>%
        rename(reg.gid = gid, rtype = type) %>%
        inner_join(tm, by = c('tid' = 'ogid')) %>%
        rename(tgt.gid = gid, ttype = type) %>%
        filter(rtype == '1-to-1', ttype == '1-to-1') %>%
        select(reg.gid, tgt.gid, score)
    rids = unique(tn$reg.gid)
    tids = unique(tn$tgt.gid)
    reg.mat = tn %>% spread(tgt.gid, score) %>%
        as.data.frame() %>% column_to_rownames(var = 'reg.gid')
    cat(sprintf("%s %s %s: %d edges, %d TFs, %d targets\n", nid, study, tag,
                nrow(tn), length(rids), length(tids)))
    fo = sprintf("%s/12_output/%s.rda", dird, nid)
    save(reg.mat, rids, tids, tn, file = fo)
    TRUE
    #}}}
}

tp = th %>% filter(nid %in% c("np16_1", sprintf("np18_%d", 1:4))) %>%
    transmute(nid=nid, study=str_replace(study,"\\d+$",''), tag=note)

pmap_lgl(tp, lift_previous_grn, tm)
#}}}

fi = file.path(dird, '08_y1h', '01.y1h.tsv')
y1h = read_tsv(fi)
ko = read_ko()

#{{{ read chipseq/dapseq/tfbs -based predictions
fi1 = '~/projects/grn/data/04_tfbs/15.regulations.tsv'
ti1 = read_tsv(fi1) %>% rename(reg.gid=tf) %>%
    filter(!str_detect(ctag, '^(cisbp)|(plantregmap)'))
#
f07 = '~/projects/grn/data/07_known_tf/10.known.tf.tgts.tsv'
ti2 = read_tsv(f07) %>% rename(ctag = tag) %>%
    mutate(ctag = str_c("REF", ctag, sep="|"))
#
bs = rbind(ti1, ti2)
bs %>% count(ctag) %>% print(n=50)
bs %>% count(ctag, reg.gid) %>% print(n=50)
#}}}

#{{{ functional annotation: GO CornCyc Y1H
dirg = '~/data/genome/Zmays_B73/61_functional'
fi = file.path(dirg, "02.go.gs.tsv")
ti = read_tsv(fi)
go_hc = ti %>% mutate(note = str_to_upper(evidence)) %>%
    mutate(note = str_replace(note, '^IEF', 'IEP')) %>%
    mutate(ctag = 'GO_HC') %>% select(ctag, grp=goid, gid, note)
go_hc_ne = go_hc %>% filter(note != 'IEP') %>% mutate(ctag=str_c(ctag, 'ne', sep='_'))
#
fi = file.path(dirg, "01.go.tsv")
ti = read_tsv(fi)
go = ti %>%
    filter(!ctag %in% c('aggregate','fanngo')) %>%
    mutate(ctag = str_c("GO",ctag,gotype, sep="_")) %>%
    select(ctag, grp=goid, gid, note=evidence)
#
ctag = "CornCyc"
fi = file.path(dirg, "07.corncyc.tsv")
ti = read_tsv(fi)
cc = ti %>% transmute(ctag = !!ctag, grp = pid, gid = gid, note = pname)
#
#ctag = 'Y1H'
#fi = '~/projects/grn/data/08_y1h/01.rds'
#y1h = readRDS(fi)
#y1h = tibble(ctag = !!ctag, grp = 'Y1H', gid = y1h$tgt.gids, note = '')
#
ctag = "PPIM"
fi = file.path(dirg, "08.ppim.tsv")
ti = read_tsv(fi)
ppi = ti %>% filter(type1 != '1-to-0', type2 != '1-to-0') %>%
    select(gid1, gid2)
ppic = ppi %>% mutate(grp = sprintf('ppi%d', 1:nrow(ppi))) %>%
    gather(tag, gid, -grp) %>%
    transmute(ctag='PPIM', grp=grp, gid=gid, note='')
#
ctags = c('li2013','liu2017','wang2018')
hs = tibble(ctag=ctags) %>%
    mutate(fi=file.path('~/projects/genome/data2',ctag,'10.rds')) %>%
    mutate(data = map(fi, readRDS)) %>%
    mutate(hs = map(data, 'hs.tgt')) %>%
    select(ctag, hs) %>% unnest(hs) %>%
    select(ctag,grp=qid,gid) %>% mutate(note=NA)
#
fun_ann = rbind(go_hc,go_hc_ne, go, cc, hs)
fun_ann %>% count(ctag)
fun_ann %>% distinct(ctag,grp) %>% count(ctag)
#}}}

#{{{ FunTFBS regulations [obsolete]
fi = file.path(dird, '03_tfbs', 'regulation_merged.txt')
ti = read_tsv(fi, col_names=c("o.reg.gid",'relation','o.tgt.gid','org','evi'))
ti %>% count(relation, org, evi)
ti %>% count(o.reg.gid)

to = ti %>% select(o.reg.gid, o.tgt.gid, evi) %>%
    inner_join(tm, by=c("o.reg.gid"="ogid")) %>%
    rename(reg.gid=gid, reg.type=type) %>%
    inner_join(tm, by=c("o.tgt.gid"="ogid")) %>%
    rename(tgt.gid=gid, tgt.type=type) %>%
    filter(reg.gid %in% gcfg$gidx$gid, tgt.gid %in% gcfg$gidx$gid) %>%
    distinct(reg.gid, tgt.gid, reg.type, tgt.type, evi)
to %>% count(reg.type,tgt.type)
to %>% count(reg.gid) %>% arrange(n)

ctags = c("FunTFBS + motif + motif_CE", "FunTFBS + motif",
          "motif + motif_CE", "motif")
tfbs = to %>% distinct(reg.gid, tgt.gid, evi) %>%
    transmute(ctag=evi, reg.gid=reg.gid, tgt.gid=tgt.gid) %>%
    mutate(ctag = str_replace_all(ctag, ", ", " + ")) %>%
    mutate(ctag = factor(ctag, levels=ctags))
tfbs %>% count(ctag)
#}}}

#{{{ add additional TF IDs
ff = '~/projects/genome/data/Zmays_B73/61_functional/06.tf.tsv'
ti = read_tsv(ff)
tf_fam = ti
tf_ids = ti$gid
length(tf_ids)
length(unique(tf_ids))

ti = read_tf_info() %>%
    select(yid, tf, gid)
ti %>% print(n=40)

x = bs %>% filter(!str_starts(ctag, 'plantregmap'), !str_starts(ctag, 'cisbp')) %>%
    distinct(reg.gid) %>% mutate(x=reg.gid %in% tf_ids) %>% print(n=50)
x$reg.gid[14]
tf_ids_n = ti %>% distinct(gid) %>% filter(str_detect(gid, '^Zm0')) %>%
    filter(!gid %in% tf_ids) %>% pull(gid)
tf_ids_n
read_tf_info() %>% filter(gid %in% tf_ids_n)
tf_ids = c(tf_ids, tf_ids_n)
length(tf_ids)
#}}}

# optional: run grn.91.tf45.R

# build GRN gold-standard dataset
res = list(bs=bs, ko=ko,
           tf_fam=tf_fam, tf_ids=tf_ids, fun_ann=fun_ann, y1h=y1h, ppi=ppi)
fo = file.path(dird, '09.gs.rds')
saveRDS(res, file=fo)
ft = file.path(dird, '09.tf.txt')
write(tf_ids, file=ft)

