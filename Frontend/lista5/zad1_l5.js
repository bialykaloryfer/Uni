
/**
 * Object to represent product. Element ProductsList
 * @typedef {Object} Product
 * @property {number} id
 * @property {string} name
 * @property {number} stock
 * @property {Date} expirationDate
 * @property {boolean} isBought
 * @property {number} unitPrice
 */


/**
 * @type {Product[]}
 */

let ProductsList = []


/**
 * To generate increasing id
 * 
 * @returns {function} id generator
 */

const idGenerator = function(){
    let i = 0
    const gen = function(){
        i += 1
        return i
    }
    return gen
}()

/**
 * Create date in UTC
 * @param {string | null} date
 * @returns {object} Date object with 0 time in UTC
 */

const dateUTC = function(date = null) {
    let dateObj;
    
    if (date === null) {
        dateObj = new Date()
    } else {
        dateObj = new Date(date)
    }
    
    return new Date(Date.UTC(
        dateObj.getFullYear(),
        dateObj.getMonth(),
        dateObj.getDate(),
    ));
}

/**
 * Push product into list of products
 * @param {string} name
 * @param {number} stock
 * @param {string} expirationDate
 * @param {boolean} isBought
 * @param {number | null} unitPrice
 */

const addProduct = function(name, stock, expirationDate, isBought, unitPrice){
    let newElement = {
        id: idGenerator(),
        name: name,
        stock: stock,
        expirationDate: dateUTC(expirationDate),
        isBought: isBought,
    };

    if (isBought) {
        newElement.unitPrice = unitPrice;
    }

    
    ProductsList.push(newElement)
}

/**
 * Remove product with selected id from list of products
 * @function removeProduct
 * @param {number} id
*/
const removeProduct = function (id) {
    ProductsList = ProductsList.filter(element => element.id !== id);
};

/**
 * Edit name of product with selected id
 * @function editName
 * @param {number} id
 * @param {string} newName
*/
const editName = function(id, newName){
    ProductsList = ProductsList.map(element => {
        if (id == element.id){
            element.name = newName
        }
        return element
    })
}

/**
 * Edit isBought of product with selected id
 * @function editIsBought
 * @param {number} id
 * @param {string} newStatus
*/
const editIsBought = function(id, newStatus){
    ProductsList = ProductsList.map(element => {
        if (id == element.id){
            element.isBought = newStatus
        }
        return element
    })
}

/**
 * Edit stock of product with selected id
 * @function editStock
 * @param {number} id
 * @param {number} newStock
*/
const editStock = function(id, newStock){
    ProductsList = ProductsList.map(element => {
        if (id == element.id){
            element.stock = newStock
        }
        return element
    })
}

/**
 * Edit stock of product with selected id
 * @function editDate
 * @param {number} id
 * @param {string} newDate
*/
const editDate = function(id, newDate){
    ProductsList = ProductsList.map(element => {
        if (id == element.id){
            element.expirationDate = dateUTC(newDate)
        }
        return element
    })
}

/**
 * Returns product with expirationDate == today
 * @function lastDayProducts
 * @returns {Product[]}
*/
const lastDayProducts = function() {
    const today = dateUTC()
    return ProductsList.filter(element => {
        return element.expirationDate.getTime() === today.getTime() && element.isBought === false;
    });
}

/**
 * Changes the price of the bought product
 * @function addPrice
 * @param {number} id
 * @param {number} price
*/
const addPrice = function(id, price) {
    ProductsList = ProductsList.map(element => {
        if (id === element.id && element.isBought === true) {
            element.unitPrice = price
        }
        return element
    })
}

/**
 * Count money spended during selected day
 * @function coutPrice
 * @param {string} date
*/
const coutPrice = function(date) {
    const targetDate = dateUTC(date);
    
    let withoutPrice = [];
    const sum = ProductsList.reduce((total, element) => {
        if (element.isBought) {
            const elementDate = dateUTC(element.expirationDate);
            
            if (elementDate.getTime() === targetDate.getTime()) {
                if (element.unitPrice == undefined) {
                    withoutPrice.push(element.name);
                    return total;
                } else {
                    return total + element.unitPrice * element.stock;
                }
            }
        }
        return total;
    }, 0);

    if (withoutPrice.length > 0) {
        console.log(`Products ${withoutPrice} have not declared a unit price. Calculated as price 0`);
    }
    return sum;
}

/**
 * Apply given functions to elements in the product list with IDs contained in `idList`.
 * @function editList
 * @param {number[]} idList 
 * @param {...Function} functions
*/
const editList = function (idList, ...functions) {
    ProductsList = ProductsList.map(element => {
        if (idList.includes(element.id)) {
            for (const fun of functions) {
                fun(element);
            }
        }
        return element;
    });
};

// example function

// should return 1-arg (element of list) function and set all needed arguments as defined inside variables
const allPriceTo = function(newPrice) {
    return function(element) {
        element.unitPrice = newPrice;
    };
};

const toEuro = function(rate) {
    return function(element) {
        element.unitPrice *= rate;
    };
};


/**
 * Pretty print of product list
 * @function printList
 * @param {Product[]} List 
*/
const printList = function(List){
    for (const element of List){
        console.log(`Element name:${element.name}, stock:${element.stock}, date:${element.expirationDate}, bought:${element.isBought}, unitPrice:${element.unitPrice}`)
    }
    console.log()
}

const today = dateUTC()
addProduct("Milk", 10, today, true, 2);
addProduct("Bread", 5, today, true);
addProduct("Cheese", 3, "2025-03-01", false, 2);
addProduct("Eggs", 20, "2025-01-01", true, 1);

console.log("Test list:")
printList(ProductsList)

removeProduct(4)
editDate(3, "2025-01-01")
editIsBought(3, true)
editName(3, "Tomato")
editStock(3, 3)
addPrice(3, 1)

console.log("After edit:")
printList(ProductsList)

console.log("Last Day Products:")
printList(lastDayProducts())

console.log("Counted Price:")
console.log(coutPrice(today))

console.log("After applying functions :")
editList([1, 2, 3], allPriceTo(1), toEuro(4))
printList(ProductsList)
