select 
mov.codp,
produto.apelido,
mov.cdNat,
movctb.dsMovCtb,
mov.dtMov,
mov.vlMov,
case when mov.fES = 1  then mov.qtMov else 0 end AS TotalEntradas,
case when mov.fES = 1  then mov.vlMov else 0 end AS vlTotalEntradas,
case when mov.fES = -1  then mov.qtMov else 0 end AS TotalSaidas,
case when mov.fES = -1  then mov.vlMov else 0 end AS vlTotalSaida,
mov.qtSaldo,
mov.seqMov
FROM mov(nolock) left outer join CCusto(nolock) on mov.cdDepto = CCusto.cdDepto
left outer join natOper(nolock) on mov.cdNat = natOper.cdNat
inner join movctb(nolock) on mov.cdMovCtb = movctb.cdMovCtb
inner join PRODUTO on mov.codp = produto.codp
where mov.CODP IN (
1715
)
and mov.cdFilial = 0 
and (mov.dtMov >= Callisto.dbo.DTI('01/01/2010'))
and (mov.dtMov <= Callisto.dbo.DTF('31/12/2019'))
and mov.seqMov is not null
and mov.fEstoque = 'S'
and mov.fNTE = 'N'
and movctb.fMov is not null
and isnull(mov.fCusto,'M') = 'M'
and (null is null or movctb.cdMovCtb is null)
and exists (select 1 from SaldoNEP where SaldoNEP.cdi=Mov.cdi)
order by dtEmissao desc

select top 1 * from mov;