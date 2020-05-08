USE Callisto
GO

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create  view vRelS001 WITH ENCRYPTION AS  
select (convert(smalldatetime, convert(char(11), mov.dtLan))) as dtLan, mov.dtMov, mov.saf, mov.numDoc, 
convert(varchar(50),Produto.codp) + ' - ' + Produto.Nome as descricao,
Produto.Apelido + ' - ' + Produto.Nome as dsApelido, produto.fvenda,
produto.nome as nmProduto, produto.codgru, mov.codp, produto.apelido, mov.cdFilial, produto.codclasse,
produto.codSub, Produto.cdiClassificacao, mov.qtMov, entCli.cdCliente, entCli.nmEntCli, mov.vlMov, mov.vlContabil, unidade.nome as nmUnidade,
mov.vlipi,mov.vlicms,mov.vlunit, subgrupo.nome as NmSubGrupo, MovCtb.cdMovCtb, MovCtb.dsMovCtb, isnull(produto.codpRevenda,-1) as codpRevenda
from mov with(noLock), produto with(noLock), entCli with(noLock), unidade with(noLock), df with(noLock), subgrupo with(noLock), MovCtb with(noLock)
where produto.codp = mov.codp and produto.codsub = subgrupo.codsub
and entCli.cdCliente = mov.cdCliente and DF.cdMovCtb = MovCtb.cdMovCtb
and mov.cdDF = df.cdDF
and mov.seqMov is not null
and mov.cdDF is not null
and mov.fES = 1
and df.fStatus = 'N'
and unidade.codunid = produto.codunid
GO
