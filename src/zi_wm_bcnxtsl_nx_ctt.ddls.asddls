@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Báo cáo nhập xuất tồn số lượng - CTT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_WM_BCNXTSL_NX_CTT
  with parameters
    P_StartDate : vdm_v_start_date,
    P_EndDate   : vdm_v_end_date
  as select from I_MaterialDocumentItem_2
{
  Plant,
  IssuingOrReceivingStorageLoc,
  Material,
  Batch,
  SalesOrder                as SDDocument,
  SalesOrderItem            as SDDocumentItem,
  InventorySpecialStockType,
  MaterialBaseUnit,
  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  sum( QuantityInBaseUnit ) as Quantity
}
where
       PostingDate                  >= $parameters.P_StartDate
  and  PostingDate                  <= $parameters.P_EndDate
  and  Plant                        = IssuingOrReceivingPlant
  and  GoodsMovementIsCancelled     is initial
  and  ReversedMaterialDocumentYear is initial
  and  ReversedMaterialDocument     is initial
  and  ReversedMaterialDocumentItem is initial
  and  Material                     is not initial
  and(
       GoodsMovementType            = '344'
    or GoodsMovementType            = '343'
  )
group by
  Plant,
  IssuingOrReceivingStorageLoc,
  Material,
  Batch,
  SalesOrder,
  SalesOrderItem,
  InventorySpecialStockType,
  MaterialBaseUnit
