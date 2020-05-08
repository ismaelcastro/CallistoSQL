USE ProelHospitalar
GO
--exec sprelC123 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, '01/02/2020', '21/02/2020', 'S', -1, -1, -1, 'S'
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
alter procedure dbo.spRelC123
  @cdFilial int,
  @cdSerie int,
  @cdCliente int,
  @cdPais int,
  @tpCliente int,
  @cdFormato int,
  @codUnid int,
  @cdTerritorio int,
  @codClasse int,
  @codGru int,
  @codSub int,
  @cdplano int,
  @cdRepres int,
  @cdRegiao int,
  @cdiClassificacao int,
  @dtini smalldatetime,
  @dtFim smalldatetime,
  @fGeraTit char(1),
  @fExclusivo int,
  @cdMovCtb int,
  @Unid1 int,
  @Devolucoes char(1)
with encryption as

  declare @spRelC123 
  Table (Plano varchar(100), Total decimal(18,5),TotalSemIpi decimal(18,5), ContabilSC decimal(18,5), 
  ContabilSemIpiSC decimal(18,5), IPI decimal(18,5), ST decimal(18,5))
  
  
  declare @nmPlano varchar(100), @Total decimal(18,5), @TotalSemIpi decimal(18,5), @ContabilSC decimal(18,5), 
  @ContabilSemIpiSC decimal(18,5), @IPI decimal(18,5), @ST decimal(18,5)

if (@cdRepres <> -1) or (@cdRegiao <> -1)
begin
  insert into @spRelC123(Plano, Total, TotalSemIpi, ContabilSC, ContabilSemIpiSC, IPI, ST)
  select nmPlano, sum(Total), sum(TotalSemIpi), sum(ContabilSC), sum(ContabilSemIpiSC), sum(IPI), sum(ST)
  from (
  select PlanoVenda.nmPlano,
		
         case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlContabil - isnull(mov.vlRemessa, 0)), 0) 
		 else 
			isNull(sum(mov.vlContabil - isnull(mov.vlRemessa, 0)), 0) 
			end as Total,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)), 0) 
			else isNull(sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)), 0) 
			end as TotalSemIPI,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then 
			(-1) * isNull(sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].[dbo].[fcTrocaZeroPorValor](isnull(ped.percSC, 100), 100)), 0) 
			else isNull(sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].[dbo].[fcTrocaZeroPorValor](isnull(ped.percSC, 100), 100)), 0) 
			end as ContabilSC,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' 
			then (-1) * isNull(sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].[dbo].[fcTrocaZeroPorValor](isnull(ped.percSC, 100), 100)), 0) 
			else isNull(sum((mov.vlContabil - mov.vlIPI - isnull([Callisto].[dbo].mov.vlRemessa, 0)) * 100 /[Callisto].[dbo].fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) 
			end as ContabilSemIpiSC,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlIPI), 0) else isNull(sum(mov.vlIPI), 0) end as IPI,
	     case when 
		 vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlST), 0) else isNull(sum(mov.vlST), 0) end as ST
  from [Callisto].[dbo].[vDFS_DevRel]
	   join [Callisto].[dbo].[mov] on mov.cdDF = vDFS_DevRel.cdDF
	   join [Callisto].[dbo].[produto] on produto.codp = mov.codp
	   join [Callisto].[dbo].[EntCli] on EntCli.cdCliente = vDFS_DevRel.cdCliente
	   join [Callisto].[dbo].[cidade] on cidade.cdCidade = EntCli.cdCidade
	   join [Callisto].[dbo].[pais] on cidade.cdpais = pais.cdpais
	   left outer join [Callisto].[dbo].[ped] on vDFS_DevRel.cdped = ped.cdped
	   left join [Callisto].[dbo].[tpcobrec] on tpcobrec.cdCobRec = vDFS_DevRel.cdCobRec
	   left join [Callisto].[dbo].[planoVenda] on PlanoVenda.cdPlano = vDFS_DevRel.cdPlano
  where produto.codpai is null and        
        vDFS_DevRel.dtEmissao between [Callisto].[dbo].[DTI](@dtini) and [Callisto].[dbo].[DTF](@dtfim) and
        (EntCli.cdterritorio = @cdterritorio or @cdterritorio = -1) and
        (produto.codunid = @codunid or @codunid = -1) and
        (produto.cdFormato = @cdFormato or @cdFormato = -1)	and
        (produto.codClasse = @codClasse or @codClasse = -1)	and
        (produto.codGru = @codGru or @codGru = -1) and
        (produto.codSub = @codSub or @codSub = -1) and
        (produto.cdCliente = @fExclusivo or @fExclusivo = -1) and
        (vDFS_DevRel.cdCliente = @cdCliente or @cdCliente = -1) and
        (pais.cdpais = @cdPais or @cdPais = -1) and
        (vDFS_DevRel.cdFilialSerie = @cdFilial or @cdFilial = -1) and
        (vDFS_DevRel.cdSerieNFS = @cdSerie or @cdSerie = -1) and
        (Produto.cdiClassificacao = @cdiClassificacao or @cdiClassificacao = -1) and
        (tpcobrec.fGeraTit = 'S' or @fGeraTit = 'N') and
        (@cdPlano = -1 or vDFS_DevRel.cdplano = @cdPlano) and
        (@cdMovCtb = -1 or vDFS_DevRel.cdMovctb in (Select str1 from [Callisto].[dbo].[tempsp] where cdTempsp = @cdMovCtb and str3 = 'S')) and
        (@cdRepres = -1 or vDFS_DevRel.cdRepres = @cdRepres)	and
        (@cdRegiao = -1 or vDFS_DevRel.cdrepres in (select cdrepres from [Callisto].[dbo].[repres] where cdregiao = @cdRegiao))	and
        (@tpCliente = -1 or vDFS_DevRel.cdcliente in ( select cdcliente from [Callisto].[dbo].EntCli where cdtpcliente = @tpCliente)) and
        (@Devolucoes = 'S' or (@Devolucoes = 'N' and isnull(vDFS_DevRel.fdevolucao, 'N') = 'N'))
  group by PlanoVenda.nmPlano, vDFS_DevRel.fdevolucao
  union all
  select PlanoVenda.nmPlano,
         case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlContabil - isnull(mov.vlRemessa, 0)), 0) 
			else isNull(sum(mov.vlContabil - isnull(mov.vlRemessa, 0)), 0) end,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)), 0) 
			else isNull(sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)), 0) end,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].[dbo].[fcTrocaZeroPorValor](isnull(ped.percSC, 100), 100)), 0) 
			else isNull(sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].[dbo].fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) end,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].[dbo].[fcTrocaZeroPorValor](isnull(ped.percSC, 100), 100)), 0) 
			else isNull(sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) end,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlIPI), 0) else isNull(sum(mov.vlIPI), 0) end,
	     case when vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlST), 0) else isNull(sum(mov.vlST), 0) end
  from [Callisto].[dbo].[vDFS_DevRel]	
	   join [Callisto].[dbo].mov on mov.cdDF = vDFS_DevRel.cdDF
	   join [Callisto].[dbo].[produto] on produto.codp = mov.codp
	   join [Callisto].[dbo].[produto] produtopai on produtopai.codp = produto.codpai
	   join [Callisto].[dbo].[EntCli] on EntCli.cdcliente = vDFS_DevRel.cdcliente
	   join [Callisto].[dbo].[cidade] on cidade.cdcidade = EntCli.cdcidade
	   join [Callisto].[dbo].[pais] on pais.cdpais = cidade.cdpais 
	   left outer join [Callisto].[dbo].[ped](nolock) on vDFS_DevRel.cdped = ped.cdped
	   left join [Callisto].[dbo].tpcobrec on tpcobrec.cdcobrec = vDFS_DevRel.cdcobrec
	   left join [Callisto].[dbo].[planoVenda] on planovenda.cdplano = vDFS_DevRel.cdplano
  where vDFS_DevRel.dtEmissao between [Callisto].[dbo].[DTI](@dtini) and [Callisto].[dbo].DTF(@dtfim) and
        (EntCli.cdterritorio = @cdterritorio or @cdterritorio = -1) and
        (produtopai.codunid = @codunid or @codunid = -1) and
        (produtopai.cdFormato = @cdFormato or @cdFormato = -1) and
        (produtopai.codClasse = @codClasse or @codClasse = -1) and
        (produtopai.codGru = @codGru or @codGru = -1) and
        (produtopai.codSub = @codSub or @codSub = -1) and
        (vDFS_DevRel.cdCliente = @cdCliente or @cdCliente = -1) and
        (pais.cdpais = @cdPais or @cdPais = -1)	and
        (vDFS_DevRel.cdFilialSerie = @cdFilial or @cdFilial = -1) and
        (vDFS_DevRel.cdSerieNFS = @cdSerie or @cdSerie = -1)	and
        (Produto.cdiClassificacao = @cdiClassificacao or @cdiClassificacao = -1) and
        (tpcobrec.fGeraTit = 'S' or @fGeraTit = 'N') and
        (@cdPlano = -1 or vDFS_DevRel.cdplano = @cdPlano) and
        (@cdMovCtb = -1 or vDFS_DevRel.cdMovctb in (Select str1 from [Callisto].[dbo].tempsp where cdTempsp = @cdMovCtb and str3 = 'S')) and
        (@cdRepres = -1 or vDFS_DevRel.cdRepres = @cdRepres)	and
        (@cdRegiao = -1 or vDFS_DevRel.cdrepres in (select cdrepres from [Callisto].[dbo].[repres] where cdregiao = @cdRegiao))	and
        (@tpCliente = -1 or vDFS_DevRel.cdcliente in ( select cdcliente from [Callisto].[dbo].[EntCli] where cdtpcliente = @tpCliente)) and
        (@Devolucoes = 'S' or (@Devolucoes = 'N' and isnull(vDFS_DevRel.fdevolucao, 'N') = 'N'))
  group by PlanoVenda.nmPlano, vDFS_DevRel.fdevolucao
  ) as planos
  group by NmPlano
end
else
begin


--INSERT @spRelC123

 
 insert into @spRelC123(Plano, Total, TotalSemIpi, ContabilSC, ContabilSemIpiSC, IPI, ST)
   select nmPlano, sum(Total), sum(TotalSemIpi), sum(ContabilSC), sum(ContabilSemIpiSC), sum(IPI), sum(ST) 
 from
 (
 select PlanoVenda.nmPlano,
         case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlContabil - isnull(mov.vlRemessa, 0)), 0) 
			else isNull(sum(mov.vlContabil - isnull(mov.vlRemessa, 0)), 0) 
			end as Total,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)), 0) 
			else isNull(sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)), 0) 
			end as TotalSemIPI,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].[dbo].fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) 
			else isNull(sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].[dbo].fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) 
			end as ContabilSC,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].[dbo].fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) 
			else isNull(sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].[dbo].fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) 
			end as ContabilSemIpiSC,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlIPI), 0) 
			else isNull(sum(mov.vlIPI), 0) end as IPI,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlST), 0) 
			else isNull(sum(mov.vlST), 0) end as ST
  from [Callisto].[dbo].vDFS_DevRel
	   join [Callisto].[dbo].[mov] on vDFS_DevRel.cdDF = mov.cdDF
	   join [Callisto].[dbo].[produto] on mov.codp = produto.codp
	   join [Callisto].[dbo].[EntCli] on EntCli.cdcliente = vDFS_DevRel.cdcliente
	   join [Callisto].[dbo].[cidade] on cidade.cdcidade = EntCli.cdcidade
	   join [Callisto].[dbo].[pais] on cidade.cdpais  = pais.cdpais
	   left outer join [Callisto].[dbo].[ped] on vDFS_DevRel.cdped = ped.cdped
	   left join [Callisto].[dbo].[tpcobrec] on vDFS_DevRel.cdcobrec = tpcobrec.cdcobrec
	   left join [Callisto].[dbo].[planoVenda] on vDFS_DevRel.cdPlano = planoVenda.cdPlano
  where produto.codpai is null and        
        vDFS_DevRel.dtEmissao between [Callisto].[dbo].DTI(@dtini) and [Callisto].dbo.DTF(@dtfim) and
        (EntCli.cdterritorio = @cdterritorio or @cdterritorio = -1) and
        (produto.codunid = @codunid or @codunid = -1) and
        (produto.cdFormato = @cdFormato or @cdFormato = -1)	and
        (produto.codClasse = @codClasse or @codClasse = -1)	and
        (produto.codGru = @codGru or @codGru = -1) and
        (produto.codSub = @codSub or @codSub = -1) and
        (produto.cdCliente = @fExclusivo or @fExclusivo = -1) and
        (vDFS_DevRel.cdCliente = @cdCliente or @cdCliente = -1) and
        (pais.cdpais = @cdPais or @cdPais = -1)	and
        (vDFS_DevRel.cdFilialSerie = @cdFilial or @cdFilial = -1) and
        (vDFS_DevRel.cdSerieNFS = @cdSerie or @cdSerie = -1)	and
        (Produto.cdiClassificacao = @cdiClassificacao or @cdiClassificacao = -1) and
        (tpcobrec.fGeraTit = 'S' or @fGeraTit = 'N') and
        (@cdPlano = -1 or vDFS_DevRel.cdplano = @cdPlano) and
        (@tpCliente = -1 or vDFS_DevRel.cdcliente in ( select cdcliente from [Callisto].[dbo].[EntCli] where cdtpcliente = @tpCliente)) and
        (@Devolucoes = 'S' or (@Devolucoes = 'N' and isnull(vDFS_DevRel.fdevolucao, 'N') = 'N'))
  group by PlanoVenda.nmPlano, vDFS_DevRel.fdevolucao
  union all
  select PlanoVenda.nmPlano,
         case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlContabil - isnull(mov.vlRemessa, 0)), 0) 
			else isNull(sum(mov.vlContabil - isnull(mov.vlRemessa, 0)), 0) end,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)), 0) 
			else isNull(sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)), 0) end,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' 
			then (-1) * isNull(sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) 
			else isNull(sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) end,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' 
			then (-1) * isNull(sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) 
			else isNull(sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)), 0) end,
	     case when 
			vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlIPI), 0) else isNull(sum(mov.vlIPI), 0) end,
	     case when 
		 vDFS_DevRel.fDevolucao = 'S' then (-1) * isNull(sum(mov.vlST), 0) else isNull(sum(mov.vlST), 0) end
  from [Callisto].[dbo].[vDFS_DevRel]
	   join [Callisto].[dbo].[mov] on vDFS_DevRel.cdDF = mov.cdDF 
	   join [Callisto].[dbo].[produto] on mov.codp = produto.codp 
	   join [Callisto].[dbo].[produto] produtopai on produto.codpai = produtopai.codp
	   join [Callisto].[dbo].[EntCli] on EntCli.cdcliente = vDFS_DevRel.cdcliente
	   join [Callisto].[dbo].[cidade] on cidade.cdcidade = EntCli.cdcidade 
	   join [Callisto].[dbo].[pais] on cidade.cdpais  = pais.cdpais
	   left outer join [Callisto].[dbo].[ped] on vDFS_DevRel.cdped = ped.cdped
	   left join [Callisto].[dbo].tpcobrec on vDFS_DevRel.cdcobrec = tpcobrec.cdcobrec
	   left join [Callisto].[dbo].planoVenda on vDFS_DevRel.cdPlano = planoVenda.cdPlano 
  where vDFS_DevRel.dtEmissao between [Callisto].[dbo].[DTI](@dtini) and [Callisto].[dbo].[DTF](@dtfim) and
        (EntCli.cdterritorio = @cdterritorio or @cdterritorio = -1) and
        (produtopai.codunid = @codunid or @codunid = -1) and
        (produtopai.cdFormato = @cdFormato or @cdFormato = -1) and
        (produtopai.codClasse = @codClasse or @codClasse = -1) and
        (produtopai.codGru = @codGru or @codGru = -1) and
        (produtopai.codSub = @codSub or @codSub = -1) and
        (vDFS_DevRel.cdCliente = @cdCliente or @cdCliente = -1) and
        (pais.cdpais = @cdPais or @cdPais = -1)	and
        (vDFS_DevRel.cdFilialSerie = @cdFilial or @cdFilial = -1) and
        (vDFS_DevRel.cdSerieNFS = @cdSerie or @cdSerie = -1)	and
        (Produto.cdiClassificacao = @cdiClassificacao or @cdiClassificacao = -1) and
        (tpcobrec.fGeraTit = 'S' or @fGeraTit = 'N') and
        (@cdPlano = -1 or vDFS_DevRel.cdplano = @cdPlano) and
        (@tpCliente = -1 or vDFS_DevRel.cdcliente in ( select cdcliente from [Callisto].[dbo].[EntCli] where cdtpcliente = @tpCliente)) and
        (@Devolucoes = 'S' or (@Devolucoes = 'N' and isnull(vDFS_DevRel.fdevolucao, 'N') = 'N'))
  group by PlanoVenda.nmPlano, vDFS_DevRel.fdevolucao
 ) as Planos
 group by nmPlano
end
/*****************************************************************/
  select @nmPlano = Plano,
         @Total = isNull(Sum(Total), 0),
         @TotalSemIpi = isNull(sum(TotalSemIpi), 0),
         @ContabilSC = isNull(sum(ContabilSC), 0),
         @ContabilSemIpiSC = isNull(sum(ContabilSemIpiSC), 0),
         @IPI = isNull(sum(IPI), 0),
         @ST = isNull(sum(ST), 0)
  from @spRelC123
  group by Plano
/*
  declare @C123 table (Codigo int, nmProduto varchar(150), Apelido varchar(70), dsClasse varchar(30), dsGrupo varchar(30), dsSubgrupo varchar(30), EstAtual decimal(18,5), qtItem1 decimal(18,5), UnidItem1 varchar(15), qtde decimal(18,5), Unidade varchar(15), nmPlano varchar(100),
                       qtTotal decimal(18,5), qtTotal1 decimal(18,5), vlTotal decimal(18,5), vlTotalSemIPI decimal(18,5), vlContabilSC decimal(18,5), vlContabilSemIPISC decimal(18,5), Total decimal(18,5), TotalSemIpi decimal(18,5), ContabilSC decimal(18,5),
                       ContabilSemIpiSC decimal(18,5), vlIPI decimal(18,5), vlST decimal(18,5), IPI decimal(18,5), ST decimal(18,5))
*/
  if (@cdRepres <> -1) or (@cdRegiao <> -1) or (@cdPais <> -1)
  begin
/*    insert into @C123 (Codigo, nmProduto, Apelido, dsClasse, dsGrupo, dsSubgrupo, EstAtual, qtItem1, UnidItem1, qtde, Unidade, nmPlano, qtTotal, qtTotal1,
					   vlTotal, vlTotalSemIPI, vlContabilSC, vlContabilSemIPISC, Total, TotalSemIpi, ContabilSC, ContabilSemIpiSC, vlIPI, vlST, IPI, ST)*/
    select 
	codigo, 
	nmProduto, 
	apelido, 
	dsClasse, 
	dsGrupo, 
	dsSubGrupo, 
	EstAtual, 
	UnidItem1, 
	Unidade, 
	nmPlano, 
	sum(qtItem1) as qtItem1, 
	sum(qtde) as qtde, 
	sum(qtTotal) as qtTotal, 
	sum(qtTotal1) as qtTotal1, 
	sum(vlTotal) as vlTotal,
	sum(vlTotalSemIPI) as vlTotalSemIPI, 
	sum(vlContabilSC) as vlContabilSC, 
	sum(vlContabilSemIPISC) as vlContabilSemIPISC, 
	sum(Total) as Total, sum(TotalSemIpi) as TotalSemIPI, 
	sum(ContabilSC) as ContabilSC, sum(ContabilSemIpiSC) as ContabilSemIpiSC, 
	sum(vlIPI) as vlIPI, 
	sum(vlST) as vlST, 
	sum(IPI) as IPI, 
	sum(ST) as ST
    from (
    select produto.codp as codigo,
           produto.nome as nmProduto,
           produto.apelido,
		   classe.Nome as dsClasse,
		   Grupo.Nome as dsGrupo,
		   Subgrupo.Nome as dsSubgrupo,
		   (select isNull(sum(est.qtSaldo), 0) 

				from [Callisto].[dbo].est with(nolock), 
				[Callisto].[dbo].LocalAcab with(nolock) where est.cdLocal = LocalAcab.cdLocal 
				and LocalAcab.cdFilial = @cdFilial and est.codp = Produto.codp) as EstAtual,

           CASE WHEN @Unid1 <> -1 THEN
				IsNull(sum(mov.qtMov) * (select IsNull(ProdUnid.coef, 0) as Coef 
				from [Callisto].[dbo].ProdUnid where ProdUnid.Codp = Produto.Codp 
				and ProdUnid.CodUnid = @Unid1),0) end as qtItem1, 
		   CASE WHEN @Unid1 <> -1 THEN
				(select Unidade.NOme from [Callisto].[dbo].Unidade(nolock) where Unidade.codUnid = @Unid1) end as UnidItem1,  
		   sum(mov.qtMov) as qtde,
				(select Unidade.Nome from [Callisto].[dbo].Unidade(nolock) where Unidade.codUnid = produto.codUnid) as Unidade,
		   @nmPlano as nmPlano,
		   sum(mov.qtMov) as qtTotal,
		   (CASE WHEN @Unid1 <> -1 THEN
		     
			IsNull(sum(mov.qtMov) * (select IsNull(ProdUnid.coef, 0) as Coef 
			from [Callisto].[dbo].ProdUnid where ProdUnid.Codp = Produto.Codp and ProdUnid.CodUnid = @Unid1),0) end) as qtTotal1,
			case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum(mov.vlContabil - isnull(mov.vlRemessa, 0)) 
			else sum(mov.vlContabil - isnull(mov.vlRemessa, 0)) end as vlTotal,
			case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum(mov.vlContabil - isnull(mov.vlIPI, 0) - isnull(mov.vlRemessa, 0)) 
				else sum(mov.vlContabil - isnull(mov.vlIPI, 0) - isnull(mov.vlRemessa, 0)) end as vlTotalSemIPI,
			case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				else sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				end as vlContabilSC,
			case when 
			vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				else sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				end as vlContabilSemIPISC,
			@Total as Total, 
			@TotalSemIpi as TotalSemIpi, 
			@ContabilSC as ContabilSC, 
			@ContabilSemIpiSC as ContabilSemIpiSC,
			case when vDFS_DevRel.fDevolucao = 'S' then (-1) * sum(isnull(mov.vlIPI, 0)) else sum(isnull(mov.vlIPI, 0)) end as vlIPI,
			case when vDFS_DevRel.fDevolucao = 'S' then (-1) * sum(isnull(mov.vlST, 0)) else sum(isnull(mov.vlST, 0)) end as vlST,
			@IPI as IPI,
		   @ST as ST
    from [Callisto].[dbo].vDFS_DevRel(nolock)
         join [Callisto].[dbo].mov(nolock) on vDFS_DevRel.cdDF = mov.cdDF
		 join [Callisto].[dbo].produto(nolock) on mov.codp = produto.codp
		 join [Callisto].[dbo].EntCli(nolock) on EntCli.cdCliente = vDFS_DevRel.cdCliente
		 join [Callisto].[dbo].Classe(nolock) on Produto.codClasse = Classe.codClasse
		 join [Callisto].[dbo].Grupo(nolock) on Produto.codClasse = Grupo.codClasse and Produto.codGru = Grupo.codGru 
		 join [Callisto].[dbo].Subgrupo(nolock) on Produto.codClasse = Subgrupo.codClasse 
		 and Produto.codGru = Subgrupo.codGru 
		 and Produto.codSub = Subgrupo.codSub 

		 join [Callisto].[dbo].Cidade(nolock) on cidade.cdcidade = EntCli.cdcidade
		 join [Callisto].[dbo].Pais(nolock) on cidade.cdpais = pais.cdpais
		 left join [Callisto].[dbo].ped(nolock) on vDFS_DevRel.cdped = ped.cdped
		 left join [Callisto].[dbo].tpcobrec(nolock) on vDFS_DevRel.cdcobrec = tpcobrec.cdcobrec
		 left join [Callisto].[dbo].planoVenda(nolock) on vDFS_DevRel.cdPlano = planoVenda.cdPlano
	where produto.codpai is null and 
		  vDFS_DevRel.dtEmissao between [Callisto].dbo.DTI(@dtini) and [Callisto].dbo.DTF(@dtfim) and
	      (EntCli.cdterritorio = @cdterritorio or @cdterritorio = -1) and
	      (produto.codunid = @codunid or @codunid = -1)	and
	      (produto.cdFormato = @cdFormato or @cdFormato = -1) and
	      (produto.codClasse = @codClasse or @codClasse = -1) and
	      (produto.codGru = @codGru or @codGru = -1) and
	      (produto.codSub = @codSub or @codSub = -1) and
	      (produto.cdCliente = @fExclusivo or @fExclusivo = -1)	and
	      (vDFS_DevRel.cdCliente = @cdCliente or @cdCliente = -1) and
	      (pais.cdpais = @cdPais or @cdPais = -1) and
	      (vDFS_DevRel.cdFilialSerie = @cdFilial or @cdFilial = -1) and
	      (vDFS_DevRel.cdSerieNFS = @cdSerie or @cdSerie = -1) and
	      (Produto.cdiClassificacao = @cdiClassificacao or @cdiClassificacao = -1) and
	      (tpcobrec.fGeraTit = 'S' or @fGeraTit = 'N') and
	      (@cdMovCtb = -1 or vDFS_DevRel.cdMovctb in (Select str1 from [Callisto].[dbo].tempsp where cdTempsp = @cdMovCtb and str3 = 'S')) and
	      (@cdRepres = -1 or vDFS_DevRel.cdRepres = @cdRepres) and
	      (@cdRegiao = -1 or vDFS_DevRel.cdrepres in (select cdrepres from [Callisto].[dbo].repres where cdregiao = @cdRegiao)) and
	      (@tpCliente = -1 or vDFS_DevRel.cdcliente in (select cdcliente from [Callisto].[dbo].EntCli where cdtpcliente = @tpCliente)) and
          (@Devolucoes = 'S' or (@Devolucoes = 'N' and isnull(vDFS_DevRel.fdevolucao, 'N') = 'N'))

    group by produto.codp, produto.nome, produto.apelido, classe.Nome, Grupo.Nome, Subgrupo.Nome, produto.codUnid, vDFS_DevRel.fdevolucao
	union all

	select produtopai.codp as codigo,
	       produtopai.nome as nmProduto,
	       produtopai.apelido,
		   classe.Nome as dsClasse, 
		   Grupo.Nome as dsGrupo, 
		   Subgrupo.Nome as dsSubgrupo,
		   (select isNull(sum(est.qtSaldo), 0) 
		   from [Callisto].[dbo].est with(nolock), [Callisto].[dbo].LocalAcab with(nolock) 
		   where est.cdLocal = LocalAcab.cdLocal and LocalAcab.cdFilial = @cdFilial and est.codp = ProdutoPai.codp) as EstAtual,           
		   CASE WHEN @Unid1 <> -1 THEN
             IsNull(sum(mov.qtMov) * (select IsNull(ProdUnid.coef, 0) as Coef 
			 from [Callisto].[dbo].ProdUnid where ProdUnid.Codp = produtopai.Codp and ProdUnid.CodUnid = @Unid1),0) 
			 end as qtItem1, 
		   CASE WHEN @Unid1 <> -1 THEN
		     (select Unidade.NOme from [Callisto].[dbo].Unidade(nolock) where Unidade.codUnid = @Unid1) 
			 end as UnidItem1, 
		   sum(mov.qtMov) as qtde,
			(select Unidade.Nome from [Callisto].[dbo].Unidade(nolock) where Unidade.codUnid = produtopai.codUnid) 
			as Unidade,
		   @nmPlano as nmPlano, 
		   sum(mov.qtMov) as qtTotal,
		   (CASE WHEN @Unid1 <> -1 THEN
				IsNull(sum(mov.qtMov) * 
				(select IsNull(ProdUnid.coef, 0) as Coef from [Callisto].[dbo].ProdUnid 
				where ProdUnid.Codp = produtopai.Codp and ProdUnid.CodUnid = @Unid1),0) end) 
				as qtTotal1,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum(mov.vlContabil - isnull(mov.vlRemessa,0)) 
				else sum(mov.vlContabil - isnull(mov.vlRemessa,0)) 
				end as vlTotal,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) 
				else sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) 
				end as vlTotalSemIpi,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				else sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				end as vlContabilSC,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				else sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				end as vlContabilSemIPISC,
		   @Total as Total, 
		   @TotalSemIpi as TotalSemIpi, 
		   @ContabilSC as ContabilSC, 
		   @ContabilSemIpiSC as ContabilSemIpiSC,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum(isnull(mov.vlIPI, 0)) else sum(isnull(mov.vlIPI, 0)) 
				end as vlIPI,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum(isnull(mov.vlST, 0)) 
				else sum(isnull(mov.vlST, 0)) 
				end as vlST,
		   @IPI as IPI,
		   @ST as ST
    from [Callisto].[dbo].vDFS_DevRel(nolock)
         join [Callisto].[dbo].mov(nolock) on vDFS_DevRel.cdDF = mov.cdDF
		 join [Callisto].[dbo].produto(nolock) on  mov.codp = produto.codp
		 join [Callisto].[dbo].produto as produtopai(nolock) on produto.codpai = produtopai.codp
		 join [Callisto].[dbo].EntCli(nolock) on EntCli.cdcliente = vDFS_DevRel.cdcliente
		 join [Callisto].[dbo].Classe(nolock) on produtopai.codClasse = Classe.codClasse
		 join [Callisto].[dbo].Grupo(nolock) on produtopai.codClasse = Grupo.codClasse and produtopai.codGru = Grupo.codGru 
		 join [Callisto].[dbo].Subgrupo(nolock) on produtopai.codClasse = Subgrupo.codClasse			 
		 and produtopai.codGru = Subgrupo.codGru 
		 and produtopai.codSub = Subgrupo.codSub

		 join [Callisto].[dbo].Cidade(nolock) on cidade.cdcidade = EntCli.cdcidade
		 join [Callisto].[dbo].Pais(nolock) on cidade.cdpais  = pais.cdpais
		 left join [Callisto].[dbo].ped(nolock) on vDFS_DevRel.cdped = ped.cdped
		 left join [Callisto].[dbo].tpcobrec(nolock) on vDFS_DevRel.cdcobrec = tpcobrec.cdcobrec
		 left join [Callisto].[dbo].planoVenda(nolock) on vDFS_DevRel.cdPlano = planoVenda.cdPlano
    where (EntCli.cdterritorio = @cdterritorio or @cdterritorio = -1) and
          (produtopai.codunid = @codunid or @codunid = -1) and
          vDFS_DevRel.dtEmissao between [Callisto].dbo.DTI(@dtini) and [Callisto].dbo.DTF(@dtfim) and
          (produtopai.cdFormato = @cdFormato or @cdFormato = -1) and
          (produtopai.codClasse = @codClasse or @codClasse = -1) and
          (produto.cdCliente = @fExclusivo or @fExclusivo = -1) and
          (produtopai.codGru = @codGru or @codGru = -1) and
          (produtopai.codSub = @codSub or @codSub = -1) and
          (vDFS_DevRel.cdCliente = @cdCliente or @cdCliente = -1) and
          (pais.cdpais = @cdPais or @cdPais = -1) and
          (vDFS_DevRel.cdFilialSerie = @cdFilial or @cdFilial = -1) and
          (vDFS_DevRel.cdSerieNFS = @cdSerie or @cdSerie = -1) and
          (Produto.cdiClassificacao = @cdiClassificacao or @cdiClassificacao = -1) and
          (tpcobrec.fGeraTit = 'S' or @fGeraTit = 'N') and
          (@cdMovCtb = -1 or vDFS_DevRel.cdMovctb in (Select str1 from [Callisto].[dbo].tempsp where cdTempsp = @cdMovCtb and str3 = 'S')) and
          (@cdRepres = -1 or vDFS_DevRel.cdRepres = @cdRepres) and
          (@cdRegiao = -1 or vDFS_DevRel.cdrepres in (select cdrepres from [Callisto].[dbo].repres where cdregiao = @cdRegiao)) and
          (@tpCliente = -1 or vDFS_DevRel.cdcliente in ( select cdcliente from [Callisto].[dbo].EntCli where cdtpcliente = @tpCliente)) and
          (@Devolucoes = 'S' or (@Devolucoes = 'N' and isnull(vDFS_DevRel.fdevolucao, 'N') = 'N'))
    group by produtopai.codp, produtopai.nome, produtopai.apelido, classe.Nome, Grupo.Nome, Subgrupo.Nome, produtopai.codUnid, vDFS_DevRel.fdevolucao
    ) as C123
    group by codigo, nmProduto, apelido, dsClasse, dsGrupo, dsSubgrupo, unidade, UnidItem1, EstAtual, nmPlano
  end
  else
  begin
  /*  insert into @C123 (Codigo, nmProduto, Apelido, dsClasse, dsGrupo, dsSubgrupo, EstAtual, qtItem1, UnidItem1, qtde, Unidade, nmPlano, qtTotal, qtTotal1,
					   vlTotal, vlTotalSemIPI, vlContabilSC, vlContabilSemIPISC, Total, TotalSemIpi, ContabilSC, ContabilSemIpiSC, vlIPI, vlST, IPI, ST)*/
    select 
	codigo, 
	nmProduto, 
	apelido, 
	dsClasse, 
	dsGrupo, 
	dsSubGrupo, 
	EstAtual, 
	UnidItem1, 
	Unidade, 
	nmPlano,
	dtEmissao,
	sum(qtItem1) as qtItem1, 
	sum(qtde) as qtde, 
	sum(qtTotal) as qtTotal, 
	sum(qtTotal1) as qtTotal1, 
	sum(vlTotal) as vlTotal,
	sum(vlTotalSemIPI) as vlTotalSemIPI, 
	sum(vlContabilSC) as vlContabilSC, 
	sum(vlContabilSemIPISC) as vlContabilSemIPISC, 
	sum(Total) as Total, 
	sum(TotalSemIpi) as TotalSemIPI, 
	sum(ContabilSC) as ContabilSC, 
	sum(ContabilSemIpiSC) as ContabilSemIpiSC, 
	sum(vlIPI) as vlIPI, 
	sum(vlST) as vlST, 
	sum(IPI) as IPI, 
	sum(ST) as ST,
	cdfilial as codEmpresa
    from (
    select produto.codp as codigo, 
           produto.nome as nmProduto, 
           produto.apelido,
		   classe.Nome as dsClasse, 
		   Grupo.Nome as dsGrupo, 
		   Subgrupo.Nome as dsSubgrupo,
		   vDFS_DevRel.dtEmissao,
		   --alteracao data
		   vDFS_DevRel.cdfilial as cdfilial,
		   (select isNull(sum(est.qtSaldo), 0) 
		   from [Callisto].[dbo].est with(nolock), 
				[Callisto].[dbo].LocalAcab with(nolock) 
				where est.cdLocal = LocalAcab.cdLocal and LocalAcab.cdFilial = @cdFilial and est.codp = Produto.codp) as EstAtual,
           CASE WHEN @Unid1 <> -1 THEN
				IsNull(sum(mov.qtMov) * (select IsNull(ProdUnid.coef, 0) as Coef 
				from [Callisto].[dbo].ProdUnid where ProdUnid.Codp = Produto.Codp and ProdUnid.CodUnid = @Unid1), 0) 
				end as qtItem1, 
		   CASE WHEN @Unid1 <> -1 THEN
				(select Unidade.NOme from [Callisto].[dbo].Unidade(nolock) 
				where Unidade.codUnid = @Unid1) 
				end as UnidItem1, 
		   sum(mov.qtMov) as qtde,
				(select Unidade.Nome 
				from [Callisto].[dbo].Unidade(nolock) 
				where Unidade.codUnid = produto.codUnid) 
				as Unidade,
		   @nmPlano as nmPlano,
		   sum(mov.qtMov) as qtTotal,
		   (CASE WHEN @Unid1 <> -1 THEN 
				IsNull(sum(mov.qtMov) * (select IsNull(ProdUnid.coef, 0) as Coef 
				from [Callisto].[dbo].ProdUnid where ProdUnid.Codp = Produto.Codp and ProdUnid.CodUnid = @Unid1),0) end) 
				as qtTotal1,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum(mov.vlContabil - isnull(mov.vlRemessa, 0)) 
				else sum(mov.vlContabil - isnull(mov.vlRemessa, 0)) 
				end as vlTotal,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' then 
				(-1) * sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) 
				else sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) 
				end as vlTotalSemIpi,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' then 
				(-1) * sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				else sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				end as vlContabilSC,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' 
				then (-1) * sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				else sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
				end as vlContabilSemIPISC,
		   @Total as Total, 
		   @TotalSemIpi as TotalSemIpi, 
		   @ContabilSC as ContabilSC, 
		   @ContabilSemIpiSC as ContabilSemIpiSC,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' then (-1) * sum(isnull(mov.vlIPI, 0)) else sum(isnull(mov.vlIPI, 0)) end as vlIPI,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' then (-1) * sum(isnull(mov.vlST, 0)) else sum(isnull(mov.vlST, 0)) end as vlST,
		   @IPI as IPI,
		   @ST as ST
    from [Callisto].[dbo].vDFS_DevRel(nolock)
		 join [Callisto].[dbo].mov(nolock) on vDFS_DevRel.cdDF = mov.cdDF
		 join [Callisto].[dbo].produto(nolock) on mov.codp = produto.codp
		 join [Callisto].[dbo].EntCli(nolock) on EntCli.cdcliente = vDFS_DevRel.cdcliente
		 join [Callisto].[dbo].Classe(nolock) on Produto.codClasse = Classe.codClasse
		 join [Callisto].[dbo].Grupo(nolock) on Produto.codClasse = Grupo.codClasse and Produto.codGru = Grupo.codGru
		 join [Callisto].[dbo].Subgrupo(nolock) on Produto.codClasse = Subgrupo.codClasse 
		 and Produto.codGru = Subgrupo.codGru 
		 and Produto.codSub = Subgrupo.codSub

		 join [Callisto].[dbo].Cidade(nolock) on cidade.cdcidade = EntCli.cdcidade
		 join [Callisto].[dbo].Pais(nolock) on cidade.cdpais  = pais.cdpais
		 left join [Callisto].[dbo].ped(nolock) on vDFS_DevRel.cdped = ped.cdped
		 left join [Callisto].[dbo].tpcobrec(nolock) on vDFS_DevRel.cdcobrec = tpcobrec.cdcobrec
		 left join [Callisto].[dbo].planoVenda(nolock) on vDFS_DevRel.cdPlano = planoVenda.cdPlano
	where produto.codpai is null and
	      vDFS_DevRel.dtEmissao between [Callisto].dbo.DTI(@dtini) and [Callisto].dbo.DTF(@dtfim) and
	      (EntCli.cdterritorio = @cdterritorio or @cdterritorio = -1) and
	      (produto.codunid = @codunid or @codunid = -1) and
	      (produto.cdFormato = @cdFormato or @cdFormato = -1) and
	      (produto.codClasse = @codClasse or @codClasse = -1) and
	      (produto.codGru = @codGru or @codGru = -1) and
	      (produto.codSub = @codSub or @codSub = -1) and
	      (produto.cdCliente = @fExclusivo or @fExclusivo = -1)	and
	      (vDFS_DevRel.cdCliente = @cdCliente or @cdCliente = -1) and
	      (pais.cdpais = @cdPais or @cdPais = -1) and
	      (vDFS_DevRel.cdFilialSerie = @cdFilial or @cdFilial = -1) and
	      (vDFS_DevRel.cdSerieNFS = @cdSerie or @cdSerie = -1) and
	      (Produto.cdiClassificacao = @cdiClassificacao or @cdiClassificacao = -1) and
	      (tpcobrec.fGeraTit = 'S' or @fGeraTit = 'N') and
	      (@cdMovCtb = -1 or vDFS_DevRel.cdMovctb in (Select str1 from [Callisto].[dbo].tempsp where cdTempsp = @cdMovCtb and str3 = 'S')) and
	      (@tpCliente = -1 or vDFS_DevRel.cdcliente in ( select cdcliente from [Callisto].[dbo].EntCli where cdtpcliente = @tpCliente)) and
          (@Devolucoes = 'S' or (@Devolucoes = 'N' and isnull(vDFS_DevRel.fdevolucao, 'N') = 'N'))
	group by produto.codp, produto.nome, produto.apelido, classe.Nome, Grupo.Nome, Subgrupo.Nome, produto.codUnid, vDFS_DevRel.fdevolucao, vDFS_DevRel.dtEmissao, vDFS_DevRel.cdfilial
	union all
	select produtopai.codp as codigo,
	       produtopai.nome as nmProduto, 
	       produtopai.apelido,
		   classe.Nome as dsClasse, 
		   Grupo.Nome as dsGrupo, 
		   Subgrupo.Nome as dsSubgrupo,
		   vDFS_DevRel.dtEmissao,
		   vDFS_DevRel.cdfilial,
				(select isNull(sum(est.qtSaldo),0) 
					from [Callisto].[dbo].est with(nolock), [Callisto].[dbo].LocalAcab with(nolock)	
					where est.cdLocal = LocalAcab.cdLocal and LocalAcab.cdFilial = @cdFilial and est.codp = Produtopai.codp) 
					as EstAtual,
				
				CASE WHEN @Unid1 <> -1 THEN
					IsNull(sum(mov.qtMov) * (select IsNull(ProdUnid.coef, 0) as Coef 
					from [Callisto].[dbo].ProdUnid where ProdUnid.Codp = produtopai.Codp and ProdUnid.CodUnid = @Unid1),0) 
					end as qtItem1, 
				
				CASE WHEN @Unid1 <> -1 THEN
					(select Unidade.NOme 
					from [Callisto].[dbo].Unidade(nolock) 
					where Unidade.codUnid = @Unid1) 
					end as UnidItem1, 
           sum(mov.qtMov) as qtde,
           (select Unidade.Nome 
				from [Callisto].[dbo].Unidade(nolock) 
				where Unidade.codUnid = produtopai.codUnid) 
				as Unidade,		
		   @nmPlano as nmPlano,
		   sum(mov.qtMov) as qtTotal,
				(CASE WHEN @Unid1 <> -1 THEN
				IsNull(sum(mov.qtMov) * (select IsNull(ProdUnid.coef, 0) as Coef 
				from [Callisto].[dbo].ProdUnid where ProdUnid.Codp = produtopai.Codp and ProdUnid.CodUnid = @Unid1),0) end) 
				as qtTotal1,
				
				case when 
				vDFS_DevRel.fDevolucao = 'S' then 
					(-1) * sum(mov.vlContabil - isnull(mov.vlRemessa, 0)) 
					else sum(mov.vlContabil - isnull(mov.vlRemessa, 0)) 
					end as vlTotal,
				case when 
				vDFS_DevRel.fDevolucao = 'S' then 
					(-1) * sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) 
					else sum(mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) end as vlTotalSemIpi,
				case when 
					vDFS_DevRel.fDevolucao = 'S' then 
					(-1) * sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
					else sum((mov.vlContabil - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
					end as vlContabilSC,
				case when 
					vDFS_DevRel.fDevolucao = 'S' then 
					(-1) * sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
					else sum((mov.vlContabil - mov.vlIPI - isnull(mov.vlRemessa, 0)) * 100 / [Callisto].dbo.fcTrocaZeroPorValor(isnull(ped.percSC, 100), 100)) 
					end as vlContabilSemIPISC,
		   @Total as Total, 
		   @TotalSemIpi as TotalSemIpi, 
		   @ContabilSC as ContabilSC, 
		   @ContabilSemIpiSC as ContabilSemIpiSC,
		   case when vDFS_DevRel.fDevolucao = 'S' then 
				(-1) * sum(isnull(mov.vlIPI, 0)) 
				else sum(isnull(mov.vlIPI, 0)) 
				end as vlIPI,
		   case when 
				vDFS_DevRel.fDevolucao = 'S' then 
				(-1) * sum(isnull(mov.vlST, 0)) 
				else sum(isnull(mov.vlST, 0)) 
				end as vlST,
		   @IPI as IPI,
		   @ST as ST
    from [Callisto].[dbo].vDFS_DevRel(nolock)
		 left join [Callisto].[dbo].ped(nolock) on vDFS_DevRel.cdped = ped.cdped
		 join [Callisto].[dbo].mov(nolock) on vDFS_DevRel.cdDF = mov.cdDF
		 join [Callisto].[dbo].tpcobrec(nolock) on vDFS_DevRel.cdcobrec = tpcobrec.cdcobrec
		 join [Callisto].[dbo].produto(nolock) on mov.codp = produto.codp
		 join [Callisto].[dbo].planoVenda(nolock) on vDFS_DevRel.cdPlano = planoVenda.cdPlano
		 join [Callisto].[dbo].produto as produtopai(nolock) on produto.codpai = produtopai.codp
		 join [Callisto].[dbo].EntCli(nolock) on EntCli.cdcliente = vDFS_DevRel.cdcliente
		 join [Callisto].[dbo].Classe(nolock) on produtopai.codClasse = Classe.codClasse
		 join [Callisto].[dbo].Grupo(nolock) on produtopai.codClasse = Grupo.codClasse and produtopai.codGru = Grupo.codGru
		 join [Callisto].[dbo].Subgrupo(nolock) on produtopai.codClasse = Subgrupo.codClasse and produtopai.codGru = Subgrupo.codGru and produtopai.codSub = Subgrupo.codSub 
		 join [Callisto].[dbo].cidade(nolock) on cidade.cdcidade = EntCli.cdcidade
		 join [Callisto].[dbo].pais(nolock) on cidade.cdpais  = pais.cdpais
	where vDFS_DevRel.dtEmissao between [Callisto].dbo.DTI(@dtini) and [Callisto].dbo.DTF(@dtfim) and
		  (EntCli.cdterritorio = @cdterritorio or @cdterritorio = -1) and
	      (produtopai.codunid = @codunid or @codunid = -1) and
	      (produtopai.cdFormato = @cdFormato or @cdFormato = -1) and
	      (produtopai.codClasse = @codClasse or @codClasse = -1) and
	      (produtopai.codGru = @codGru or @codGru = -1) and
	      (produtopai.codSub = @codSub or @codSub = -1) and
	      (vDFS_DevRel.cdCliente = @cdCliente or @cdCliente = -1) and
	      (pais.cdpais = @cdPais or @cdPais = -1) and
	      (vDFS_DevRel.cdFilialSerie = @cdFilial or @cdFilial = -1) and
	      (vDFS_DevRel.cdSerieNFS = @cdSerie or @cdSerie = -1) and
	      (Produto.cdiClassificacao = @cdiClassificacao or @cdiClassificacao = -1) and
	      (tpcobrec.fGeraTit = 'S' or @fGeraTit = 'N') and
	      (produto.cdCliente = @fExclusivo or @fExclusivo = -1) and
	      (@cdMovCtb = -1 or vDFS_DevRel.cdMovctb in (Select str1 from [Callisto].[dbo].tempsp where cdTempsp = @cdMovCtb and str3 = 'S')) and
	      (@tpCliente = -1 or vDFS_DevRel.cdcliente in ( select cdcliente from [Callisto].[dbo].EntCli where cdtpcliente = @tpCliente)) and
          (@Devolucoes = 'S' or (@Devolucoes = 'N' and isnull(vDFS_DevRel.fdevolucao, 'N') = 'N'))
    group by produtopai.codp, produtopai.nome, produtopai.apelido, classe.Nome, Grupo.Nome, Subgrupo.Nome, produtopai.codUnid, vDFS_DevRel.fdevolucao,
	vDFS_DevRel.dtEmissao, vDFS_DevRel.cdfilial
    ) as C123
    group by codigo, nmProduto, apelido, dsClasse, dsGrupo, dsSubgrupo, unidade, UnidItem1, EstAtual, nmPlano, dtEmissao, cdfilial
end
GO
