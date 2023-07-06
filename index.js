function errorHandlingExample(req, res) {
    try {
        //some code...
        if (response.phoneNumber.length < 9) {
            throw { statusCode: 400 }
        }
    } catch (error) {
        let response = {};
        switch(error.statusCode) {
            case 400: {
                response = { message: 'lower then 9 chars' };
            }
            break;
        }
        res.send(response);
    }
}