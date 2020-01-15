USE ProelHospitalar
GO

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO 
CREATE PROCEDURE dbo.recebimentosVsRecebidos
	@cdFilial int,
	@dtini smalldatetime,
	@dtFim smalldatetime
	with encryption as

	DECLARE @recebimentosVsRecebidos Table( TotalReceber decimal(18,5), TotalRecebido decimal(18,5) )
	DECLARE @TotalReceber decimal(18,5), @TotalRecebido decimal(18,5)
	
	--Titulos à receber 
	SET @TotalReceber = (SELECT SUM(Tit.VlBruto) FROM [Callisto].[dbo].vfTituloCRE AS Tit
	INNER JOIN [Callisto].[dbo].BaixaRecTit AS Baixat ON Tit.cdRec = Baixat.cdRec
	INNER JOIN [Callisto].[dbo].BaixaRec AS BaixaR ON Baixat.cdBordRec = BaixaR.cdBordRec
	WHERE Tit.dtVencto BETWEEN '01/09/2019' AND '30/09/2019'
	AND BaixaR.fDevolucao <> 'S'
	--notas fiscal canceladas
	AND Baixat.Status <> 'C'
	AND Tit.cdFilial = 0)

	--Titulos Recebidos
	SET @TotalRecebido = (SELECT SUM(Tit.VlBruto) as 'Total Recebido' FROM [Callisto].[dbo].vfTituloCRE AS Tit
	INNER JOIN [Callisto].[dbo].BaixaRecTit AS Baixat ON Tit.cdRec = Baixat.cdRec
	INNER JOIN [Callisto].[dbo].BaixaRec AS BaixaR ON Baixat.cdBordRec = BaixaR.cdBordRec 
	AND Baixat.cdRecebimento = BaixaR.cdRecebimento
	WHERE Tit.dtPag BETWEEN '01/09/2019' AND '23/09/2019'
	-- desconsidera as devoluções
	AND BaixaR.fDevolucao <> 'S'
	AND Tit.cdFilial = 0)
	
	insert into @recebimentosVsRecebidos values (@TotalReceber, @TotalRecebido)

	SELECT @TotalReceber as totalReceber, @TotalRecebido as totalRecebido from @recebimentosVsRecebidos;