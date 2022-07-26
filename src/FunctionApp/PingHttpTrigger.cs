using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

using Newtonsoft.Json;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.OpenApi.Models;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using System.Net;

namespace OCAProject
{
    public class PingHttpTrigger
    {
        private readonly IMyService _service;

        public PingHttpTrigger(IMyService service){ // 의존성을 없애주려는 코드
            this._service = service ?? throw new ArgumentNullException(nameof(service)); // service에 값이 없으면 에러나고 이 func 실행시키지 말아라 
        }

        [FunctionName(nameof(PingHttpTrigger))] // 문자열로 하드코딩하는 것보다 참조하기 편해짐


        [OpenApiOperation(operationId: "Ping", tags: new[] {"greeting"})] // OpenApi 등록과정 
        [OpenApiSecurity(schemeName: "function_key", schemeType: SecuritySchemeType.ApiKey, Name = "x-functions-key", In = OpenApiSecurityLocationType.Header)]
        // OpenApi creential을 설정
        // 스키마네임은 OpenAPi에서 function_key라는 이름으로 정의하겠다. 
        // function key는 앤드 포인트마다 다르다 앤ㄷ 포인트 하나당 메서드 하나라고 볼 수 있음!! 
        [OpenApiParameter(name: "name", In = ParameterLocation.Query, Required=true, Description ="Name of ther person to greet.")]
        // OpenApi parameter를 설정
        // 인풋값이 들어왔다~~~~ 쿼리 스트링의 name에 데이터를 뽑아오겠다. 
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "application/json", bodyType: typeof(ResponseMessage), Description="Greeting Message")]
        // OpenApi response를 설정, 즉 아웃풋

        public IActionResult Run( // end point 만 담당 
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "ping")] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string name = req.Query["name"]; // 쿼리만 뽑고 

            // string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            // dynamic data = JsonConvert.DeserializeObject(requestBody);
            // name = name ?? data?.name; 필요없음

            // string responseMessage = string.IsNullOrEmpty(name)
            //     ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
            //     : $"Hello, {name}. This HTTP triggered function executed successfully.";

            //여기에 비즈니스 로직이 존재 , 우리가 고민해봐야 할 부분 
            // var service = new MyService(); 의존성 제거 
            var result = this._service.GetMessage(name);

            var res = new ResponseMessage() {Message = result};

            return new OkObjectResult(res);
        }
    }
}

public class ResponseMessage{

    [JsonProperty("response_message")] // 응답 메세지의 json 객체를 우리 맘대로 바꿔줄 수 있음 이거 없으면 message만 뜬다
    public string Message{get; set;}
}

public interface IMyService{
    //인터페이스 
    string GetMessage(string name);
}

public class MyService : IMyService{ // 의존성을 준것!! 
    public string GetMessage(string name){
        string responseMessage = string.IsNullOrEmpty(name)
                ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
                : $"Hello, {name}. This HTTP triggered function executed successfully.";

        return responseMessage;
    }
}