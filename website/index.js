const counter = document.querySelector(".counter-number"); // This line selects the first HTML element with the class counter-number and assigns it to the counter variable. 
// a method in JavaScript used to select the first element in the DOM (Document Object Model) that matches a specified CSS selector. It allows you to interact with or manipulate HTML elements directly.
// selector: A string representing a CSS selector (e.g., .class, #id, or a tag like div). 
async function updateCounter() { // The updateCounter function is marked as async, meaning it can use await inside it to handle asynchronous operations.
    let response = await fetch("https://lxazrwhnrj.execute-api.us-east-1.amazonaws.com/prod/viewer-count") // Fetch the JSON data from the API.
    let data = await response.json(); // Parse the JSON response. 
    counter.innerHTML = `Views: ${data.view_count}`; //replaces the value of the counter number class with the new data number received from lambda.
    // counter.innerHTML is a property of an HTML element that represents the content inside that element, including any HTML tags. 
}

updateCounter();


// counter.innerHTML explanation

//<div class="counter-number">Old Content</div>
//<script>
//    const counter = document.querySelector(".counter-number");
//    counter.innerHTML = "New Content";
//    console.log(counter.innerHTML); // Outputs: "New Content"
//</script>

// document.querySelector(".counter-number") selects the <div> with the class counter-number. 
// counter.innerHTML = "New Content" replaces the existing content ("Old Content") with "New Content". 
