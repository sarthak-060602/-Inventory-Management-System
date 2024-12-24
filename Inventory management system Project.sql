--ASSIGNMENT-2
--SUBMITTED BY-
--SARTHAK BHALLA(137872222)
--HARSHDEEP SINGH(171289218)
--SANJANA(152304266)


CREATE OR REPLACE PROCEDURE find_customer(
    customer_id IN NUMBER,
    found OUT NUMBER
) AS
BEGIN
    SELECT 1 INTO found
    FROM customers
    WHERE customer_id = find_customer.customer_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        found := 0;
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Error: Multiple records found for customer ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE || ': ' || SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE find_product (
    productId IN NUMBER,
    price OUT products.list_price%TYPE,
    productName OUT products.product_name%TYPE
) IS
    v_category_id NUMBER;
BEGIN
    SELECT product_name, list_price, category_id
    INTO productName, price, v_category_id
    FROM products
    WHERE product_id = find_product.productId;

    IF v_category_id IN (2, 5) AND EXTRACT(MONTH FROM SYSDATE) IN (11, 12) THEN
        price := price * 0.9; -- Apply 10% discount
    END IF;
EXCEPTION
    WHEN no_data_found THEN
        price := 0;
        productName := NULL;
    WHEN too_many_rows THEN
        DBMS_OUTPUT.PUT_LINE('Error: Multiple rows found for the product ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


CREATE OR REPLACE FUNCTION generate_order_id RETURN NUMBER IS
    max_order_id NUMBER;
BEGIN
    SELECT NVL(MAX(order_id), 0) + 1 INTO max_order_id FROM orders;
    RETURN max_order_id;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN NULL;
END;
/


CREATE OR REPLACE PROCEDURE add_order (
    customer_id IN NUMBER,
    new_order_id OUT NUMBER
) IS
BEGIN
    SELECT generate_order_id() INTO new_order_id FROM DUAL;

    INSERT INTO orders (order_id, customer_id, status, salesman_id, order_date)
    VALUES (new_order_id, customer_id, 'Shipped', 56, SYSDATE);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE add_order_item (
    orderId IN order_items.order_id%TYPE,
    itemId IN order_items.item_id%TYPE,
    productId IN order_items.product_id%TYPE,
    quantity IN order_items.quantity%TYPE,
    price IN order_items.unit_price%TYPE
) IS
BEGIN
    INSERT INTO order_items (order_id, item_id, product_id, quantity, unit_price)
    VALUES (orderId, itemId, productId, quantity, price);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/



CREATE OR REPLACE PROCEDURE customer_order (
    customerId IN NUMBER,
    orderId IN OUT NUMBER
) IS
BEGIN
    SELECT order_id INTO orderId
    FROM orders
    WHERE customer_id = customerId AND order_id = orderId;
EXCEPTION
    WHEN no_data_found THEN
        orderId := 0;
    WHEN too_many_rows THEN
        DBMS_OUTPUT.PUT_LINE('Error: Multiple rows found for the order ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE display_order_status (
    orderId IN NUMBER,
    status OUT orders.status%TYPE
) IS
BEGIN
    SELECT status INTO status
    FROM orders
    WHERE order_id = orderId;
EXCEPTION
    WHEN no_data_found THEN
        status := NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/




CREATE OR REPLACE PROCEDURE cancel_order (
    orderId IN NUMBER,
    cancelStatus OUT NUMBER
) IS
    orderStatus VARCHAR2(20);
BEGIN
    SELECT status INTO orderStatus
    FROM orders
    WHERE order_id = orderId;

    IF orderStatus = 'Canceled' THEN
        cancelStatus := 1; 
    ELSIF orderStatus = 'Shipped' THEN
        cancelStatus := 2;
    ELSE
        UPDATE orders
        SET status = 'Canceled'
        WHERE order_id = orderId;
        cancelStatus := 3;
    END IF;
EXCEPTION
    WHEN no_data_found THEN
        cancelStatus := 0; 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

