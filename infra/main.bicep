param name string // 외부에서 필수적으로 값을 넘겨줘야 하는 애 
param location string = resourceGroup().location // 외부에서 값을 입력받아도 되고 입력이 없으면 지금 정의한 default를 따름! 
param env string = 'dev' // default 값(dev) 정의!! 
param loc string = 'krc'
param pubName string = 'owner'
param pubEmail string

var rg = 'rg-${name}-${env}' // 파라미터를 받아서 이렇게 리소스 이름으로 설정함
var funcappname = 'funcapp-${name}-${loc}'

/*Api Management*/
resource apiman 'Microsoft.ApiManagement/service@2021-12-01-preview' = { // 어플리케이션을 여러개 쓰고 싶으면 이름 반드시 다르게!! 
  name : 'apiman-${name}-${loc}'
  location : location
  sku : { //sku는 애플리케이션의 종류가 여러 개 이기 때문에 더 자세하게 정의한 것!
    capacity: 2
    name : 'Standard' 
  }
  properties: {
    publisherEmail : pubEmail
    publisherName : pubName
  }
  
}

/*Azure function*/
resource fncapp 'Microsoft.Web/sites@2022-03-01' = {
  name: funcappname
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appserplan.id // 종속성!! 
    siteConfig:{
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: stacc.id
        }
      ]
    }
  }
}

/*Azure storage account*/
resource stacc 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name : 'sac${name}${loc}'
  location : location
  sku : {
    name :'Standard_LRS'
  }
  kind : 'StorageV2'
  properties: {
    accessTier: 'Cool'
  }
}

/*Azure App service plan*/
resource appserplan 'Microsoft.Web/serverfarms@2022-03-01' = { // 어플리케이션을 여러개 쓰고 싶으면 이름 반드시 다르게!! 
  name: 'cspaln-${name}-${loc}'
  location:location
  kind: 'functionapp'
  sku:{ 
    name: 'Y1'
    capacity: 1

  }
  properties:{
    reserved:true // 리눅스로 운영 
  }
}

/*Azure Application insight*/
resource appin 'Microsoft.Insights/components@2020-02-02' ={
  name: 'appin-${name}-${loc}'
  location: location
  kind : 'phone'
  properties:{
    Application_Type: 'other'
    WorkspaceResourceId: wrkanl.id

  }
}

/*Azure log analytics workspace*/
resource wrkanl 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name : 'wrkanl-${name}-${loc}'
  location : location
  properties:{
    retentionInDays: 30
    sku : {
      name : 'CapacityReservation'
      capacityReservationLevel: 100 // 100의 배수여야 한다...
    }
  }
}

output rn string = rg // 이 bicep을 실행시키고 나서의 결과값!! 다른 bicep이 참조할 수 있음 
