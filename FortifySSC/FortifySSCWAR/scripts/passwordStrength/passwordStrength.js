var isLowerThanMinPasswordScore = true;
function passwordCheck(password, actionUrl, minPasswordScore){
    var config = {
    	password : password
	};
    var MINIMAL_KEY_STROKES = 4;

    var settings = {
    	url : actionUrl,
		type : "POST",
		data : JSON.stringify(config),
		contentType : "application/json;charset=UTF-8",
		success : function (result) {
            appendStrengthBar(result);
            isLowerThanMinPasswordScore = result.data.score < minPasswordScore;
            return isLowerThanMinPasswordScore;
        }
	};
    if(password.length > MINIMAL_KEY_STROKES){
        return $.ajax(settings);
    }else{
        document.getElementById("passwordDescription").innerHTML = '<span>Poor</span>';
        document.getElementById("passwordStrengthColor").className = "strength1";
        document.getElementById("passwordStrengthGray").className = "gray1";
        return null;
    }
}

function appendStrengthBar(result){
    var desc = ["Very Poor", "Poor", "Weak", "Medium", "Strong", "Very strong"];
	var score = result.data.score + 1;
    document.getElementById("passwordDescription").innerHTML = '<span>' + desc[score] + '</span>';
    document.getElementById("passwordStrengthColor").className = "strength" + score;
    document.getElementById("passwordStrengthGray").className = "gray" + score;
}