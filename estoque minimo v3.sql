USE [ProelHospitalar]
GO

/****** Object:  StoredProcedure [dbo].[RelS005v3]    Script Date: 30/04/2020 09:51:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 --exec RelS005v3 0, '01/01/2019', '31/12/2019', 15, 7, -1;

 ALTER procedure [dbo].[RelS005v3]
 @cdFilial int,
 @dataIni smalldatetime,
 @dataFim  smalldatetime,
 @prazoEntrega int,
 @diasSeguranca int,
 @CCusto int

 as
 DECLARE @consumoTotal decimal(18,5), @diasDoPeriodo int, @DiasProxCompra int, @MesesDoPeriodo int;


 set @diasDoPeriodo = DATEDIFF(day, @dataIni,@dataFim);
 set @MesesDoPeriodo = DATEDIFF(MONTH, @dataIni,@dataFim) + 1;

 
 SELECT @consumoTotal =
  SUM(vRelS005.qtMov) FROM 
  [ProelHospitalar].[dbo].vRelS005
  inner join [Callisto].[dbo].produto on vRelS005.codp = produto.codp
  WHERE vRelS005.cdFilial=@cdFilial AND 
  vRelS005.dtMov>= [Callisto].[dbo].[DTI](@dataIni) AND 
  vRelS005.dtMov<= [Callisto].[dbo].[DTF](@dataFim)
  and produto.fVenda = 'A'
  and (@CCusto = -1 or vRelS005.id = @CCusto) 
  AND vRelS005.codp not in (1034)

  
 SELECT 
 codp,
 codigoAlternativo,
 nmProduto,
 nmUnidade,
 format(vlMov, 'C', 'PT-br') as vlMovSaida,
 format(qtMov, 'N') as qtMovSaida,
 format(SaidaMediaMensal, 'N') SaidaMediaMensal,
 format(EstoqueMinimo, 'N') EstoqueMinimo,
 format(SALDO, 'N') as SaldoAtual,
 floor(diasDeCoberturaAtual) diasCoberturaAtual,
 format(dbo.ufn_ADD_WORKING_DAYS(null, diasDeCoberturaAtual), 'd', 'en-gb') as dtProximaCompra,
 concat(format((qtMov/@consumoTotal * 100), 'N'),' %') as ABC,
 format(vlUnitUltimaCompra, 'C', 'PT-br') ValorUltimaCompra,
 Fornecedor,
 format(qtdUltimaCompra, 'N') qtdUltimaCompra,
 format(dtUltimaCompra, 'd', 'en-gb') dtUltimaCompra,
 NF,
 format(vlTotalNF, 'C', 'PT-br') as vlTotalNF
 
 FROM(
 SELECT
 vRelS005.nmUnidade, 
 vRelS005.nmProduto,
 vRelS005.codp, 
 produto.apelido codigoAlternativo,
 vRelS005.cdFilial,
 sum(vRelS005.vlMov) vlMov, 
 sum(vRelS005.qtMov) qtMov,
 sum(vRelS005.qtMov)/@MesesDoPeriodo as SaidaMediaMensal,
 (sum(vRelS005.qtMov)/@diasDoPeriodo) * (@prazoEntrega + @diasSeguranca) AS EstoqueMinimo,
 (SELECT top 1 FIRST_VALUE(qtSaldo) OVER(ORDER BY seqMov desc) FROM [callisto].[dbo].mov M where M.CODP = vRelS005.codp and cdFilial = 0) SALDO,
 (SELECT top 1 FIRST_VALUE(qtSaldo) OVER(ORDER BY seqMov desc) FROM [callisto].[dbo].mov M where M.CODP = vRelS005.codp and cdFilial = 0) / (sum(vRelS005.qtMov)/@diasDoPeriodo)
	AS diasDeCoberturaAtual,
isnull(
	(SELECT top 1 FIRST_VALUE(vlUnit + (ISNULL(vlIPI / qtMov, 0))) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
	WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial and mov.fES = 1
	and mov.cdMovCtb in (126,152,155,156,162,170,174,214,118, 112, 110, 111)
	and mov.hstMov is not null and mov.hstMov not in ('Estorno', 'Devolução')),
	isnull(
		(SELECT top 1 FIRST_VALUE(vlUnit + (ISNULL(vlIPI / qtMov, 0))) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
		WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial and mov.fES = 1
		and mov.cdMovCtb in (126,152,155,156,162,170,174,214,118, 112, 110, 111)
		and mov.hstMov is null),
		
		(SELECT top 1 FIRST_VALUE(vlUnit + (ISNULL(vlIPI / qtMov, 0))) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
		WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial and mov.fES = 1
		and mov.cdMovCtb in (126,152,155,156,162,170,174,214,118, 112, 110, 111))
		)
	)	
 as vlUnitUltimaCompra,
 isnull(
	(SELECT top 1 FIRST_VALUE(CONCAT(MOV.cdCliente, ' - ',EntCli.RazaoSocial) ) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
	join [Callisto].[dbo].EntCli ON mov.cdCliente = EntCli.cdCliente 
	WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial 
	and fES = 1 and mov.cdMovCtb in (118, 112, 174, 110, 156, 111)
	and mov.hstMov is not null and mov.hstMov not in ('Estorno', 'Devolução') ),
	isnull(
		
		(SELECT top 1 FIRST_VALUE(CONCAT(MOV.cdCliente, ' - ',EntCli.RazaoSocial) ) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
		join [Callisto].[dbo].EntCli ON mov.cdCliente = EntCli.cdCliente 
		WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial 
		and fES = 1 and mov.cdMovCtb in (118, 112, 174, 110, 156, 111)
		and mov.hstMov is null),
	
		(SELECT top 1 FIRST_VALUE(CONCAT(MOV.cdCliente, ' - ',EntCli.RazaoSocial) ) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
		join [Callisto].[dbo].EntCli ON mov.cdCliente = EntCli.cdCliente 
		WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial 
		and fES = 1 and mov.cdMovCtb in (118, 112, 174, 110, 156, 111))
	)
 ) 
 as Fornecedor,
 isnull(
	(SELECT top 1 FIRST_VALUE(qtMov) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
	WHERE Mov.codp = vRelS005.codp and cdFilial = 0  
	and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111)
	and mov.hstMov is not null and mov.hstMov not in ('Estorno', 'Devolução')),
	
	isnull(
	(SELECT top 1 FIRST_VALUE(qtMov) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
	WHERE Mov.codp = vRelS005.codp and cdFilial = 0  
	and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111)
	and mov.hstMov is null),

	(SELECT top 1 FIRST_VALUE(qtMov) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
	WHERE Mov.codp = vRelS005.codp and cdFilial = 0  
	and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111))		
	)
	
 ) 
 as qtdUltimaCompra,
 ISNULL(
	(SELECT top 1 FIRST_VALUE(dtmov) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
		WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial	
		and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111)
		and mov.hstMov is not null and mov.hstMov not in ('Estorno', 'Devolução'))
	,
	isnull(
		
		(SELECT top 1 FIRST_VALUE(dtmov) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
		WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial	
		and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111)
		and mov.hstMov is null)
		,
		(SELECT top 1 FIRST_VALUE(dtmov) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
		WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial	
		and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111))
	)

 )
 as dtUltimaCompra,
	ISNULL(
		(SELECT top 1 FIRST_VALUE(numDoc) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
		WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial
		and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111)
		and mov.hstMov is not null and mov.hstMov not in ('Estorno', 'Devolução')),
	
		isnull(
		(SELECT top 1 FIRST_VALUE(numDoc) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
		WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial
		and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111)
		and mov.hstMov is null),
	
		(SELECT top 1 FIRST_VALUE(numDoc) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
		WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial
		and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111))
		)
	
 ) as NF, 
 ISNULL(
	(SELECT top 1 FIRST_VALUE(vlContabil) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
	WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial
	and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111)
	and mov.hstMov is not null and mov.hstMov not in ('Estorno', 'Devolução')),

	isnull(
	(SELECT top 1 FIRST_VALUE(vlContabil) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
	WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial
	and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111)
	and mov.hstMov is null),

	(SELECT top 1 FIRST_VALUE(vlContabil) OVER(ORDER BY seqMov desc) FROM [Callisto].[dbo].Mov 
	WHERE Mov.codp = vRelS005.codp and mov.cdFilial = vRelS005.cdFilial
	and fES = 1 and cdMovCtb in (118, 112, 174, 110, 156, 111))
	)
 )

 as vlTotalNF
 

 FROM   
 [ProelHospitalar].[dbo].vRelS005
 inner join [Callisto].[dbo].produto ON produto.codp = vRelS005.codp
 WHERE  
 vRelS005.cdFilial=@cdFilial AND 
 vRelS005.dtMov>= [Callisto].[dbo].[DTI](@dataIni) AND 
 vRelS005.dtMov<= [Callisto].[dbo].[DTF](@dataFim)
 and produto.fVenda = 'A'
 and (@CCusto = -1 or vRelS005.id = @CCusto)
 AND vRelS005.codp not in (1034) 
 group by 
 vRelS005.nmUnidade, 
 vRelS005.nmProduto,  
 vRelS005.cdFilial,
 vRelS005.codp,
 produto.apelido,
 vRelS005.id
 
 HAVING SUM(vRelS005.qtMov) > 0
)AS estoque  
order by ABC desc
GO


