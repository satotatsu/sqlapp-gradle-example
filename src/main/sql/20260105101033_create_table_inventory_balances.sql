CREATE TABLE inventory_balances (
    warehouse_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,

    quantity DECIMAL(15,2) NOT NULL,

    PRIMARY KEY (
        warehouse_id,
        product_id
    )
);