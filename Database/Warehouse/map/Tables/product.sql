﻿/*
##################################################################
Note that map tables are seeded with an IDENTITY of 1000.  The 
intent is to reserve a block of key values that can be used
for Governance or other manually specified values.  Every map
table must have a primary key on the named key column and a 
grain (unique) index on the combined UID and source_key columns.
##################################################################
*/

CREATE TABLE [map].[product] (
    [product_key] INT           IDENTITY (1000, 1) NOT NULL,
    [source_key]  INT           NOT NULL,
    [product_uid] VARCHAR (200) NOT NULL,
    [process_batch_key]   INT           NOT NULL,
    CONSTRAINT [map_product_pk] PRIMARY KEY CLUSTERED ([product_key] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [map_product_gx]
    ON [map].[product]([product_uid] ASC, [source_key] ASC);

