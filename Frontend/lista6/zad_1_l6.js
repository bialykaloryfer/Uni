
// wyzwanie 1
console.log("wyzwanie 1")

console.log(capitalize("alice"));

function capitalize (str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
};


// wyzwanie 2
console.log("wyzwanie 2")

const capitalizeSentence = (sen) => {
    return sen.split(" ").map(capitalize).join(" ");
  };

console.log(capitalizeSentence("alice"));
console.log(capitalizeSentence("alice in wonderland"));


// wyzwanie 3
console.log("wyzwanie 3")

const ids = [];
const generateId = () => {
  let id = 0;

  do {
    id++;
  } while (ids.includes(id));

  ids.push(id);
  return id;
};

const ids_2 = new Set();
const generateId_2 = () => {
  let id = 0;

  do {
    id++;
  } while (ids_2.has(id));

  ids_2.add(id);
  return id;
};


console.time("generateId");
for (let i = 0; i < 3000; i++) {
  generateId();
}
console.timeEnd("generateId");

console.time("generateId_2");
for (let i = 0; i < 3000; i++) {
    generateId_2();
}
console.timeEnd("generateId_2");


// wyzwanie 4
console.log("wyzwanie 4")

function compareObjects(obj1, obj2) {
    const obj1Keys = Object.keys(obj1);
    const obj2Keys = Object.keys(obj2);

    set1 = new Set (obj1Keys)
    set2 = new Set (obj2Keys)

    if (set1.symmetricDifference(set2).size) {
        return false;
    }

    for (let key of obj1Keys) {
        if (typeof obj1[key] === 'object' && obj1[key] !== null && typeof obj2[key] === 'object' && obj2[key] !== null) {
            if (!compareObjects(obj1[key], obj2[key])) {
                return false;
            }
        } else {
            if (obj1[key] !== obj2[key]) {
                return false;
            }
        }
    }

    return true;
}

const obj1 = {
    name: "Alice",
    age: 25,
    address: {
      city: "Wonderland",
      country: "Fantasy",
    },
  };
  
  const obj2 = {
    name: "Alice",
    age: 25,
    address: {
      city: "Wonderland",
      country: "Fantasy",
    },
  };
  
  const obj3 = {
    age: 25,
    address: {
      city: "Wonderland",
      country: "Fantasy",
    },
    name: "Alice",
  };
  
  const obj4 = {
    name: "Alice",
    age: 25,
    address: {
      city: "Not Wonderland",
      country: "Fantasy",
    },
  };
  
  const obj5 = {
    name: "Alice",
  };
  
  console.log("Should be True:", compareObjects(obj1, obj2));
  console.log("Should be True:", compareObjects(obj1, obj3));
  console.log("Should be False:", compareObjects(obj1, obj4));
  console.log("Should be True:", compareObjects(obj2, obj3));
  console.log("Should be False:", compareObjects(obj2, obj4));
  console.log("Should be False:", compareObjects(obj3, obj4));
  console.log("Should be False:", compareObjects(obj1, obj5));
  console.log("Should be False:", compareObjects(obj5, obj1));

  console.log("wyzwanie 5")

  let library = []

const NotEmptyStr = (str) =>{
    if(!str || typeof str !== "string"){
        throw new Error("Error: title is empty or not a str"); 
    }
    return str
}

const validateTitle = (title) => {
    return NotEmptyStr(title)
}

const validateAuthor = (author) => {
    return NotEmptyStr(author)
}

const validatePages = (pages) => {
    if(pages <= 0 || typeof pages !== "number"){
        throw new Error("Error: pages nr is negative or is not a number"); 
    }
    return pages
}

const validateIsAvaliable = (isAvaliable) => {
    if(typeof isAvaliable !== "boolean"){
        throw new Error("Error: isAvaliable is not true/false")
    }

    return isAvaliable
}

const validateRatings = (ratings) => {
    if (!Array.isArray(ratings)) {
        return false;
    }

    if (ratings.length === 0 || ratings.every(num => typeof num === "number" && num >= 0 && num <= 5)) {
        return ratings;
    }

    throw new Error("Error: ratings is not array with numbers between 0 and 5");
};


const addBookToLibrary = (title, author, pages, isAvailable, ratings) => {
  library.push({
    title: validateTitle(title),
    author: validateAuthor(author),
    pages: validatePages(pages),
    available: validateIsAvaliable(isAvailable),
    ratings: validateRatings(ratings),
  });
};

addBookToLibrary("Biblia", "Jacek Sutryk", 123, true, [3,4,5])
console.log(library)

console.log("wyzwanie 6")
library = []
const testCases = [
    { testCase: ["", "Author", 200, true, []], shouldFail: true },
    { testCase: ["Title", "", 200, true, []], shouldFail: true },
    { testCase: ["Title", "Author", -1, true, []], shouldFail: true },
    { testCase: ["Title", "Author", 200, "yes", []], shouldFail: true },
    { testCase: ["Title", "Author", 200, true, [1, 2, 3, 6]], shouldFail: true },
    {
      testCase: ["Title", "Author", 200, true, [1, 2, 3, "yes"]],
      shouldFail: true,
    },
    { testCase: ["Title", "Author", 200, true, [1, 2, 3, {}]], shouldFail: true },
    { testCase: ["Title", "Author", 200, true, []], shouldFail: false },
    { testCase: ["Title", "Author", 200, true, [1, 2, 3]], shouldFail: false },
    { testCase: ["Title", "Author", 200, true, [1, 2, 3, 4]], shouldFail: false },
    {
      testCase: ["Title", "Author", 200, true, [1, 2, 3, 4, 5]],
      shouldFail: false,
    },
    {
      testCase: ["Title", "Author", 200, true, [1, 2, 3, 4, 5]],
      shouldFail: false,
    },
  ];

const evaluateTests = (tests) => {
    const check = (test, nr) => {
        let args = test["testCase"]
        let target = test["shouldFail"]
        process.stdout.write(`test nr: ${nr} `)
        try {
            addBookToLibrary(...args);
            if (target) {
                console.log("Test failed: ");
            } else {
                console.log("Test passed: ");
            }
        } catch (error) {
            if (target) {
                console.log(`Test passed: ${error}  `);
            } else {
                console.log(`Test failed: ${error}  `);
            }
        }
        console.log(args)
    }

    tests.forEach((test, index) => check(test, index + 1));

}

evaluateTests(testCases)

console.log("wyzwanie 7")

const addBooksToLibrary = (books) => {
    books.map(elem => addBookToLibrary(...elem))
    return library
}

const books = [
    ["Alice in Wonderland", "Lewis Carroll", 200, true, [1, 2, 3]],
    ["1984", "George Orwell", 300, true, [4, 5]],
    ["The Great Gatsby", "F. Scott Fitzgerald", 150, true, [3, 4]],
    ["To Kill a Mockingbird", "Harper Lee", 250, true, [2, 3]],
    ["The Catcher in the Rye", "J.D. Salinger", 200, true, [1, 2]],
    ["The Hobbit", "J.R.R. Tolkien", 300, true, [4, 5]],
    ["Fahrenheit 451", "Ray Bradbury", 200, true, [3, 4]],
    ["Brave New World", "Aldous Huxley", 250, true, [2, 3]],
    ["The Alchemist", "Paulo Coelho", 200, true, [1, 2]],
    ["The Picture of Dorian Gray", "Oscar Wilde", 300, true, [4, 5]],
  ];
  
  addBooksToLibrary(books);
  console.log(library);
