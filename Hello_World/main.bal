//Ballerina Helllo world service
import ballerina/http;

function HelloWorld(string name) returns string {
    return "Hello, " + name;
}
    
service / on new http:Listener(9090) {
    resource function get sayHello(string name) returns string {
        string response = HelloWorld(name);
        return response;
    }
}