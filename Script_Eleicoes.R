dirElei2014 <- 'Z:\\Dados\\TSE\\Eleicoes2014'

library(data.table)
library(SOAR)
Store(dirElei2014, lib = Rdata, lib.loc = dirElei2014)
Attach(lib = Rdata, lib.loc = dirElei2014)
Objects(lib = Rdata, lib.loc = dirElei2014)
Attach(lib = TbDepFed, lib.loc = dirElei2014)
Objects(lib = TbDepFed, lib.loc = dirElei2014)

cols <- c('DATA_GERACAO','HORA_GERACAO','ANO_ELEICAO','NUM_TURNO','DESCRICAO_ELEICAO',
          'SIGLA_UF','SIGLA_UE','CODIGO_MUNICIPIO','NOME_MUNICIPIO','NUMERO_ZONA',
          'CODIGO_CARGO','NUMERO_CAND','SQ_CANDIDATO','NOME_CANDIDATO','NOME_URNA_CANDIDATO',
          'DESCRICAO_CARGO','COD_SIT_CAND_SUPERIOR','DESC_SIT_CAND_SUPERIOR',
          'CODIGO_SIT_CANDIDATO','DESC_SIT_CANDIDATO','CODIGO_SIT_CAND_TOT',
          'DESC_SIT_CAND_TOT','NUMERO_PARTIDO','SIGLA_PARTIDO','NOME_PARTIDO',
          'SEQUENCIAL_LEGENDA','NOME_COLIGACAO','COMPOSICAO_LEGENDA','TOTAL_VOTOS',
          'TRANSITO')
cols <- tolower(cols)

ufs <- c('AC','AL','AP','AM','BA','CE','DF','ES','GO',
         'MA','MT','MS','MG','PA','PB','PR','PE','PI',
         'RJ','RN','RS','RO','RR','SC','SP','SE','TO')

x <- readLines(paste0(dirElei2014,'\\temp_codigo.R'))
### atencao loop variando em todos os arquivos dos estados (pode ser lento)
for(ufatual in ufs){
  print(ufatual)
  y <-  gsub('2014_AC',paste0('2014_',ufatual),x)  
  write.table(y,paste0(dirElei2014,'\\script_',ufatual,'.R'),col.names=F,row.names=F,quote=F)
  source(paste0(dirElei2014,'\\script_',ufatual,'.R'), echo = TRUE)
  rm(y)
}
rm(cols,x,ufatual)

search()
detach('Rdata')

table(tbvoto2014_AC_DepFed$eleito,tbvoto2014_AC_DepFed$eleicaosimples)

tbvoto2014_DepFed <- list()
for(ufatual in ufs){
  tbvoto2014_DepFed[[ufatual]] <- get(paste0('tbvoto2014_',ufatual,'_DepFed'))
}
names(tbvoto2014_DepFed)

tbvoto2014_DepFed <- do.call(rbind,tbvoto2014_DepFed)

table(tbvoto2014_DepFed$eleito)

x <- data.frame(table(tbvoto2014_DepFed$sigla_uf,tbvoto2014_DepFed$eleito,tbvoto2014_DepFed$eleicaosimples))
y <- data.frame(table(tbvoto2014_DepFed$sigla_uf,tbvoto2014_DepFed$eleito))
a <- y[y$Var2 == "ELEITO 2014",]
b <- x[x$Var2 == 'ELEITO 2014' & x$Var3 == 'ELEITOS PERCENTUAL ABSOLUTO',]
c <- x[x$Var2 == 'NAO ELEITO 2014' & x$Var3 == 'ELEITOS PERCENTUAL ABSOLUTO',]
rownames(a) <- a$Var1
rownames(b) <- b$Var1
rownames(c) <- c$Var1

tb_ufs <- data.frame(matrix(c('11','Rondônia','RO',
                              '12','Acre','AC',
                              '13','Amazonas','AM',
                              '14','Roraima','RR',
                              '15','Pará','PA',
                              '16','Amapá','AP',
                              '17','Tocantins','TO',
                              '21','Maranhão','MA',
                              '22','Piauí','PI',
                              '23','Ceará','CE',
                              '24','Rio Grande do Norte','RN',
                              '25','Paraíba','PB',
                              '26','Pernambuco','PE',
                              '27','Alagoas','AL',
                              '28','Sergipe','SE',
                              '29','Bahia','BA',
                              '31','Minas Gerais','MG',
                              '32','Espírito Santo','ES',
                              '33','Rio de Janeiro','RJ',
                              '35','São Paulo','SP',
                              '41','Paraná','PR',
                              '42','Santa Catarina','SC',
                              '43','Rio Grande do Sul','RS',
                              '50','Mato Grosso do Sul','MS',
                              '51','Mato Grosso','MT',
                              '52','Goiás','GO',
                              '53','Distrito Federal','DF'), ncol = 3, byrow = TRUE),stringsAsFactors = FALSE)
colnames(tb_ufs) <- c('coduf','uf','sguf')
tb_ufs[1,]


tabela_final <- cbind.data.frame(a[ufs,c(1,3)],b[ufs,4],c[ufs,c(4)])
tabela_final$Var1 <- as.character(tabela_final$Var1)
colnames(tabela_final) <- c('UF','Num. Dep. Fed','Eleitos 14 e perc','Não eleitos e perc')
tabela_final <- rbind(tabela_final,tabela_final[28,])
tabela_final[28,1] <- '*Tot'
tabela_final[28,2:4] <- colSums(tabela_final[1:27,2:4])
tabela_final <- merge(tb_ufs,tabela_final,by.x='sguf',by.y='UF',all=T)
tabela_final[1,2] <- '00'
tabela_final[1,3] <- 'Brasil'
tabela_final <- tabela_final[order(tabela_final$coduf),]
library(xlsx)
xlsx::write.xlsx(tabela_final,paste0(dirElei2014,'\\tabela_final.xlsx'), col.names = T, row.names = F)
