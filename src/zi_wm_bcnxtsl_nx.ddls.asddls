@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Báo cáo nhập xuất tồn số lượng - NX'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_WM_BCNXTSL_NX
  with parameters
    P_StartDate : vdm_v_start_date,
    P_EndDate   : vdm_v_end_date
  as select from I_MaterialStock_2
{
  key I_MaterialStock_2.Plant,
  key I_MaterialStock_2.StorageLocation,
  key I_MaterialStock_2.Material,
  key I_MaterialStock_2.Batch,
  key I_MaterialStock_2.SDDocument,
  key I_MaterialStock_2.SDDocumentItem,
  key I_MaterialStock_2.InventorySpecialStockType,
      I_MaterialStock_2.MaterialBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum( I_MaterialStock_2.MatlStkIncrQtyInMatlBaseUnit ) as TotalReceiptQty,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum( I_MaterialStock_2.MatlStkDecrQtyInMatlBaseUnit ) as TotalIssueQty
}
where
      I_MaterialStock_2.MatlDocLatestPostgDate >= $parameters.P_StartDate
  and I_MaterialStock_2.MatlDocLatestPostgDate <= $parameters.P_EndDate
group by
  I_MaterialStock_2.Plant,
  I_MaterialStock_2.StorageLocation,
  I_MaterialStock_2.Material,
  I_MaterialStock_2.Batch,
  I_MaterialStock_2.SDDocument,
  I_MaterialStock_2.SDDocumentItem,
  I_MaterialStock_2.InventorySpecialStockType,
  I_MaterialStock_2.MaterialBaseUnit
