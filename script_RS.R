
voto2014_RS <- fread(input = paste0(dirElei2014,'\\votacao_candidato_munzona_','2014_RS','.txt'),
                     sep = ';', header = FALSE, col.names = cols)

mode(voto2014_RS$total_votos) <- 'integer'
voto2014_RS$desc_sit_cand_tot <- iconv(voto2014_RS$desc_sit_cand_tot,to='ASCII//TRANSLIT')

voto2014_RS_DepFed <- subset(voto2014_RS,descricao_cargo == 'DEPUTADO FEDERAL')

tbvoto2014_RS_DepFed <- voto2014_RS_DepFed[,list(total_votos = sum(total_votos)),
                                           by = list(sigla_uf,sigla_ue,numero_cand,nome_candidato,
                                                     nome_urna_candidato,desc_sit_cand_superior,
                                                     codigo_sit_candidato,desc_sit_candidato,
                                                     codigo_sit_cand_tot,desc_sit_cand_tot,
                                                     numero_partido,sigla_partido,nome_partido)]

tbvoto2014_RS_DepFed <- as.data.frame(tbvoto2014_RS_DepFed)

tbvoto2014_RS_DepFed <- tbvoto2014_RS_DepFed[order(tbvoto2014_RS_DepFed$total_votos, decreasing = TRUE),]

tbvoto2014_RS_DepFed$eleito <- 'NAO ELEITO 2014'
tbvoto2014_RS_DepFed$eleito[is.element(tbvoto2014_RS_DepFed$desc_sit_cand_tot,
                                c("ELEITO POR QP","ELEITO POR MEDIA"))] <- 'ELEITO 2014'

num_eleitos <- sum(tbvoto2014_RS_DepFed$eleito == 'ELEITO 2014')

#eleicao simples = apenas os 46 mais votados
tbvoto2014_RS_DepFed$eleicaosimples <- 'NAO ELEITOS PERCENTUAL ABSOLUTO'
tbvoto2014_RS_DepFed$eleicaosimples[1:num_eleitos] <- 'ELEITOS PERCENTUAL ABSOLUTO'
rm(num_eleitos)

Store(voto2014_RS, voto2014_RS_DepFed, lib = Rdata, lib.loc = dirElei2014)
Store(tbvoto2014_RS_DepFed, lib = TbDepFed, lib.loc = dirElei2014)
