import ballerina/io;
import ballerina/http;
import ballerina/lang.'int;

type customer record {
    string name;
    string email;
    string phone;
};

//customer array to save customer details
customer[] customerList = [];
int booking_id = 1;

service /bookHotel on new http:Listener(9090) {
    
    resource function post bookHotel(@http:Payload customer payload) returns string {
        //get customer details from the payload
        json payload_json = payload.toJson();
        io:println(payload_json);

        //add customer details to the customer array
        io:println("Customer name: " + payload.name);
        io:println("Customer email: " + payload.email);
        io:println("Customer phone: " + payload.phone);
        customerList.push(payload);
        booking_id = booking_id + 1;
        return "Hotel booked successfully for " + payload.name + "Booking ID: " + booking_id.toString();

    }

    //get customer details by booking id
    resource function get getCustomerDetails(string bookingId) returns customer|error {
        //convert booking id to int
        int booking_id = check int:fromString(bookingId);
        if (booking_id == 0 || booking_id > customerList.length()) {
            return error("Invalid booking id");
        }
        else{
            customer customerDetails = customerList[booking_id-1];
            return customerDetails;
        }
        
    }
}
