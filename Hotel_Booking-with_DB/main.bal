import ballerina/io;
import ballerina/http;
import ballerina/lang.'int;
import ballerinax/googleapis.sheets as sheets;

type customer record {
    string name;
    string email;
    string phone;
};

//customer array to save customer details
customer[] customerList = [];
int booking_id = 1;

# specifying Google Sheet ID
configurable string GoogleSheetID = "{{GOOGLE_SHEET_ID}}}}";

// Get token from https://developers.google.com/oauthplayground/
final sheets:ConnectionConfig spreadsheetConfig = {
        auth: {
            clientId: "{{CLIENT_ID}}",
            clientSecret: "{{CLIENT_SECRET}}",
            refreshUrl: "https://oauth2.googleapis.com/token",
            refreshToken: "{{REFRESH_TOKEN}}}}"
        }
    };

final sheets:Client spreadsheetClient = check new (spreadsheetConfig);

isolated function AddToSheet(string[] row, string sheet = "Sheet1") returns error?{
    var resp = check spreadsheetClient->appendRowToSheet(GoogleSheetID, sheet, row); 
    return resp;
}

service /bookHotel on new http:Listener(9090) {
    
    resource function post bookHotel(@http:Payload customer payload) returns string|error {
        //get customer details from the payload
        json payload_json = payload.toJson();
        io:println(payload_json);

        //add customer details to the customer array
        io:println("Customer name: " + payload.name);
        io:println("Customer email: " + payload.email);
        io:println("Customer phone: " + payload.phone);

        // create customer record row
        string[] row = [payload.name, payload.email, payload.phone, booking_id.toString()];
        // call google sheets api to add customer details to the sheet
        var _ = check AddToSheet(row);

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

// main function for service
public function main() returns error? {

    
}