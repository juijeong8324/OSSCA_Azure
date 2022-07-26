param name string // 필수적으로 값을 넘겨줘야 하는 애 
param location string = resourceGroup().location
param env string = 'dev' // env는 기본값이 dev임 
param loc string = 'krc'

var rg = 'rg-${name}-${env}' // 파라미터를 받아서 이렇게 이름으로 설정하겠댜
var funcappname = 'funcapp-${name}-${loc}'

resource fncapp 'Micosoft.Web/sites@2022-03-01' = {
  name: funcappname
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: csplan.id // 종속성!! 
    siteConfig:{
      appSettings: [
        {
          name: 'AzureWebJobs'
        }
      ]
    }
  }
}
// 이름이 달라야함!! 어플리케이션 2개 쓰고 시프면!! 
resource csplan 'Microsoft.Web/sites@2022-03-01'={
  name: 'cspaln-${name}-${loc}'
  location:location
  kind: 'functionapp'
  sku:{
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0

  }
  properties:{
    reserved:true // 리눅스로 운영 
  }
}

resource st 'Microsoft.Web/sites@2022-03-01' ={
  name: 'st${name}${loc}'
  location: location
  sku:{
    name: 'Standard'
  }
}
output rn string = rg // 이 bicep을 실행시키고 나서의 결과값!! 다른 bicep이 참조할 수 있음 
