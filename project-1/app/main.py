import csv
import gzip
import os
import random

from datetime import datetime, timedelta
from decimal import Decimal
from app.common.dbContext import dbContext
from app.common.minioClient import minioClient

# function
def getRandomPercentage():
    rnd = random.uniform(1, 100)
    
    if rnd % 25 == 0: # Abnormally 4 of 100
        return random.uniform(0.20, 0.30)
        
    return random.uniform(0.02, 0.05) # normally 96 of 100

def getCurrentPeriod():
    currentDate = datetime.now()
    currentPeriod = f"{currentDate.year}_{currentDate.month:02}"

    return currentPeriod

def getDateRange(period):
    year, month = map(int, period.split('_'))
    firstDate = datetime(year, month, 1)
    
    if month == 12:
        lastDate = datetime(year + 1, 1, 1) - timedelta(days=1)
    else:
        lastDate = datetime(year, month + 1, 1) - timedelta(days=1)
    
    return firstDate, lastDate

# context

def getInstances(db = dbContext(), isClose = False):
    try:
        instances = db.executeQuery("""
            select ti.* 
            from transaction.t_instances ti
            where ti.effectived_date <= current_timestamp
            and (ti.expired_date >= current_timestamp or ti.expired_date is NULL)                
        """)

        return instances
    except Exception as e:
        print(f"error in getInstances: {e}")
    finally:
        if(isClose == True):
            db.close()

def getInstancePeriod(db = dbContext(), period = None, instanceId = None, isClose = False):
    print("Starting function: getInstancePeriod")

    try:
        if period == None:
            period = getCurrentPeriod()

        instanceUsage = db.executeQuery(f"""
            select * from transaction.t_instance_usages tiu 
            where tiu.period = '{period}'
            and tiu.instance_id = '{instanceId}'
        """)

        return instanceUsage
    except Exception as e:
        print(f"getInstancePeriod: {e}")
    finally:
        if(isClose == True):
            db.close()

def genInstancePeriod(db = dbContext(), period = None, instance = None, isClose = False):
    print("Starting function: genInstancePeriod")

    try:
        if period is None:
            period = getCurrentPeriod()

        pricing_model = getInstancePricingModel(db=db, instance=instance)

        firstDate, lastDate = getDateRange(period)

        instanceUsage = {
            "instance_id": instance.id,
            "pricing_model_id": instance.pricing_model_id,
            "period": period,
            "period_begin_date": firstDate,
            "period_end_date": lastDate,
            "usage": Decimal('0'),
            "usage_date": datetime.now(),
            "unblended_cost": Decimal('0'),
            "unblended_rate": Decimal(pricing_model[0].price_per_unit)
        }

        query = """
        INSERT INTO transaction.t_instance_usages (
            instance_id,
            pricing_model_id,
            period,
            period_begin_date,
            period_end_date,
            usage,
            usage_date,
            unblended_cost,
            unblended_rate
        ) VALUES (
            %s, %s, %s, %s, %s, %s, %s, %s, %s
        )
        """

        params = (
            instanceUsage["instance_id"],
            instanceUsage["pricing_model_id"],
            instanceUsage["period"],
            instanceUsage["period_begin_date"],
            instanceUsage["period_end_date"],
            instanceUsage["usage"],
            instanceUsage["usage_date"],
            instanceUsage["unblended_cost"],
            instanceUsage["unblended_rate"],
        )

        db.executeNonQuery(query, params)
        print("Instance usage inserted successfully.")
    except Exception as e:
        print(f"Error genInstancePeriod: {e}")
    finally:
        if(isClose == True):
            db.close()

def getInstancePricingModel(db = dbContext(), instance = None, isClose = False):
    print("Start function: getInstancePricingModel")

    try:
        pricingModel = db.executeQuery(f"""
            select * from product.m_pricing_model mpm 
            where mpm.id = '{instance.pricing_model_id}'
        """)

        return pricingModel
    except Exception as e:
        print(f"Error getInstancePricingModel: {e}")
    finally:
        if(isClose == True):
            db.close()

def updateInstancePeriod(db = dbContext(), period = None, instance = None, isClose = False):
    print("Starting function: updateInstancePeriod")

    try:
        if period is None:
            period = getCurrentPeriod()

        instanceUsage = getInstanceUsage(db=db, period=period, instance=instance)
        
        if not instanceUsage:
            print("No instance usage found for the provided parameters.")
            return
        
        instance = instanceUsage[0]
        instanceDict = {
            "id": instance.id,
            "usage": instance.usage,
            "unblended_rate": instance.unblended_rate,
            "unblended_cost": instance.unblended_cost
        }

        if instanceDict["usage"] == Decimal('0E-12') or instanceDict["usage"] == Decimal('0'):
            instanceDict["usage"] = Decimal(random.uniform(1.0, 100.0))
        else:
            randomPercentage = Decimal(getRandomPercentage())
            instanceDict["usage"] *= (1 + randomPercentage)

        instanceDict["unblended_cost"] = instanceDict["unblended_rate"] * instanceDict["usage"]

        query = """
        UPDATE transaction.t_instance_usages
        SET 
            usage = %s, 
            unblended_cost = %s, 
            updated_date = current_timestamp
        WHERE id = %s 
        AND period = %s
        """

        params = (instanceDict["usage"], instanceDict["unblended_cost"], instanceDict["id"], period)
        db.executeNonQuery(query, params)
        print("Instance usage updated successfully.")
    except Exception as e:
        print(f"Error in updateInstancePeriod: {e}")
    finally:
        if(isClose == True):
            db.close()

def getInstanceUsage(db = dbContext(), period = None, instance = None, isClose = False):
    print("Starting function: getInstanceUsage")

    try:
        if period is None:
            period = getCurrentPeriod()

        query = """
            SELECT *
            FROM transaction.t_instance_usages
            WHERE instance_id = %s 
            AND period = %s
        """

        params = (
            instance.id,
            period
        )

        return db.executeQuery(query, params)
    except Exception as e:
        print("Error in getInstanceUsage: {e}")
    finally:
        if(isClose == True):
            db.close()

def getAccountTransactions(db = dbContext(), isClose = False):
    try:
        results = db.executeQuery("""
            select 
                ti.id,
                ti.code,
                ti.name,
                ti.effectived_date,
                ti.expired_date,
                mp.code as product_code,
                mp.name as product_name,
                mpc.code as product_category_code,
                mpc.name as product_category_name,
                mpm.billing_cycle as billing_period,
                mpm.price_per_unit,
                mpm.pricing_unit,
                mpm.usage_value as usage_value,
                mpm.usage_type as usage_type,
                mpm.tier
            from transaction.t_instances ti 
            inner join product.m_products mp on ti.product_id = mp.id 
            inner join product.m_product_categories mpc on mp.product_category_id = mpc.id
            inner join product.m_pricing_model mpm on ti.pricing_model_id = mpm.id
        """)

        return results
    except Exception as e:
        print(f"Error in getAccountTransactions: {e}")
    finally:
        if(isClose == True):
            db.close()

def exportFile(db = dbContext(), period = None, parentAccountId = None, parentAccountCode = None, isClose = False):
    print("Start function exportFile")

    try:
        if period == None:
            period = getCurrentPeriod()

        query = f"""
                    (
                        SELECT 
                            tiu.id AS line_item_id,
                            concat(tiu.period_begin_date, '/', tiu.period_end_date) as time_interval,
                            tiu.period,
                            'AWS' AS billing_entity,
                            'Usage' AS line_item_type,
                            COALESCE(ma2.code, ma.code) AS payer_account_id,
                            COALESCE(ma2.name, ma.name) AS payer_account_name,
                            tiu.period_begin_date as period_start_date,
                            tiu.period_end_date as period_end_date,
                            ma.code AS usage_account_id,
                            ma.name AS usage_account_name,
                            tiu.usage as usage_amount,
                            tiu.unblended_cost AS unblended_cost,
                            tiu.unblended_rate,
                            ti.code AS instance_id,
                            ti.name AS instance_name,
                            mp.code AS product_code,
                            mp.name AS product_name,
                            mps.unit as usage_type,
                            LOWER(mps.code) AS product_spec_code,
                            mps.specification AS product_spec_desc
                        FROM master.m_accounts ma
                        LEFT JOIN master.m_accounts ma2 ON ma.parent_account_id = ma2.id
                        LEFT JOIN master.m_account_discount_programs madp ON ma.id = madp.account_id 
                        LEFT JOIN master.m_discount_programs mdp ON madp.discount_program_id = mdp.id
                        LEFT JOIN (
                            SELECT 
                                madp2.account_id AS parent_account_id,
                                mdp2.code AS code,
                                madp2.min_value
                            FROM master.m_account_discount_programs madp2
                            INNER JOIN master.m_discount_programs mdp2 ON madp2.discount_program_id = mdp2.id
                            WHERE madp2.is_forwarded = TRUE
                        ) parent_discount_program ON ma.parent_account_id = parent_discount_program.parent_account_id
                        INNER JOIN transaction.t_instances ti ON ti.account_id = ma.id
                        INNER JOIN product.m_product_specifications mps ON mps.id = ti.product_spec_id
                        INNER JOIN product.m_products mp ON mp.id = ti.product_id
                        INNER JOIN transaction.t_instance_usages tiu ON tiu.instance_id = ti.id
                        WHERE (ma.id = '{parentAccountId}' OR ma.parent_account_id = '{parentAccountId}')
                        AND tiu.period = '{period}'
                    )
                    UNION ALL
                    (
                        SELECT 
                            tiu.id AS line_item_id,
                            concat(tiu.period_begin_date, '/', tiu.period_end_date) as time_interval,
                            tiu.period,
                            'AWS' AS billing_entity,
                            CASE 
                                WHEN COALESCE(parent_discount_program.code, mdp.code) IS NOT NULL THEN 
                                    INITCAP(LOWER(COALESCE(parent_discount_program.code, mdp.code))) || ' Discount'
                                ELSE 
                                    NULL
                            END AS line_item_type,
                            COALESCE(ma2.code, ma.code) AS payer_account_id,
                            COALESCE(ma2.name, ma.name) AS payer_account_name,
                            tiu.period_begin_date as period_start_date,
                            tiu.period_end_date as period_end_date,
                            ma.code AS usage_account_id,
                            ma.name AS usage_account_name,
                            tiu.usage as usage_amount,
                            CASE 
                                WHEN COALESCE(parent_discount_program.min_value, madp.min_value) IS NOT NULL THEN 
                                    -1 * tiu.unblended_cost * (COALESCE(parent_discount_program.min_value, madp.min_value) / 100)
                                ELSE 
                                    0
                            END AS unblended_cost,
                            NULL AS unblended_rate,
                            ti.code AS instance_id,
                            ti.name AS instance_name,
                            mp.code AS product_code,
                            mp.name AS product_name,
                            NULL as usage_type,
                            NULL AS product_spec_code,
                            NULL AS product_spec_desc
                        FROM master.m_accounts ma
                        LEFT JOIN master.m_accounts ma2 ON ma.parent_account_id = ma2.id
                        LEFT JOIN master.m_account_discount_programs madp ON ma.id = madp.account_id 
                        LEFT JOIN master.m_discount_programs mdp ON madp.discount_program_id = mdp.id
                        LEFT JOIN (
                            SELECT 
                                madp2.account_id AS parent_account_id,
                                mdp2.code AS code,
                                madp2.min_value
                            FROM master.m_account_discount_programs madp2
                            INNER JOIN master.m_discount_programs mdp2 ON madp2.discount_program_id = mdp2.id
                            WHERE madp2.is_forwarded = TRUE
                        ) parent_discount_program ON ma.parent_account_id = parent_discount_program.parent_account_id
                        INNER JOIN transaction.t_instances ti ON ti.account_id = ma.id
                        INNER JOIN product.m_products mp ON mp.id = ti.product_id
                        INNER JOIN transaction.t_instance_usages tiu ON tiu.instance_id = ti.id
                        WHERE (ma.id = '{parentAccountId}' OR ma.parent_account_id = '{parentAccountId}')
                        AND tiu.period = '{period}'
                    )
                    UNION ALL
                    (
                        SELECT 
                            tiu.id AS line_item_id,
                            concat(tiu.period_begin_date, '/', tiu.period_end_date) as time_interval,
                            tiu.period,
                            'AWS Marketplace' AS billing_entity,
                            'Usage' AS line_item_type,
                            COALESCE(ma2.code, ma.code) AS payer_account_id,
                            COALESCE(ma2.name, ma.name) AS payer_account_name,
                            tiu.period_begin_date as period_start_date,
                            tiu.period_end_date as period_end_date,
                            ma.code AS usage_account_id,
                            ma.name AS usage_account_name,
                            tiu.usage as usage_amount,
                            tiu.unblended_cost AS unblended_cost,
                            NULL AS unblended_rate,
                            ti.code AS instance_id,
                            ti.name AS instance_name,
                            mp.code AS product_code,
                            mp.name AS product_name,
                            mp.unit as usage_type,
                            NULL AS product_spec_code,
                            NULL AS product_spec_desc
                        FROM master.m_accounts ma
                        LEFT JOIN master.m_accounts ma2 ON ma.parent_account_id = ma2.id
                        INNER JOIN marketplace.t_instances ti ON ti.account_id = ma.id
                        INNER JOIN marketplace.m_products mp ON mp.id = ti.product_id
                        INNER JOIN marketplace.t_instance_usages tiu ON tiu.instance_id = ti.id
                        WHERE (ma.id = '{parentAccountId}' OR ma.parent_account_id = '{parentAccountId}')
                        AND tiu.period = '{period}'
                    )
                    UNION ALL
                    (
                        SELECT 
                            tiu.id AS line_item_id,
                            concat(tiu.period_begin_date, '/', tiu.period_end_date) as time_interval,
                            tiu.period,
                            'AWS' AS billing_entity,
                            'Tax' AS line_item_type,
                            COALESCE(ma2.code, ma.code) AS payer_account_id,
                            COALESCE(ma2.name, ma.name) AS payer_account_name,
                            tiu.period_begin_date as period_start_date,
                            tiu.period_end_date as period_end_date,
                            ma.code AS usage_account_id,
                            ma.name AS usage_account_name,
                            tiu.usage as usage_amount,
                            ROUND(tiu.unblended_cost * 0.07, 12) AS unblended_cost,
                            NULL AS unblended_rate,
                            ti.code AS instance_id,
                            ti.name AS instance_name,
                            mp.code AS product_code,
                            mp.name AS product_name,
                            NULL as usage_type,
                            NULL AS product_spec_code,
                            NULL AS product_spec_desc
                        FROM master.m_accounts ma
                        LEFT JOIN master.m_accounts ma2 ON ma.parent_account_id = ma2.id
                        INNER JOIN transaction.t_instances ti ON ti.account_id = ma.id
                        INNER JOIN product.m_products mp ON mp.id = ti.product_id
                        INNER JOIN transaction.t_instance_usages tiu ON tiu.instance_id = ti.id
                        WHERE (ma.id = '{parentAccountId}' OR ma.parent_account_id = '{parentAccountId}')
                        AND tiu.period = '{period}'
                    )
                    ORDER BY 
                        usage_account_id,
                        billing_entity,
                        instance_id,
                        line_item_type;
        """

        transactions = db.executeQuery(query, (parentAccountId,))


        if transactions != None and len(transactions) > 0:
            outputDir = "transactions"
            os.makedirs(outputDir, exist_ok=True)

            outputCsvPath = f"{outputDir}/{parentAccountCode}_CUR_{period}.csv"
            print(f"Output CSV path: {outputCsvPath}")

            outputGzPath = f"{outputCsvPath}.gz"
            print(f"Gzip path: {outputGzPath}")

            columnNames = db.getColumnNames(query)

            with open(outputCsvPath, mode='w', newline='') as csv_file:
                writer = csv.writer(csv_file)
                writer.writerow(columnNames)
                writer.writerows(transactions)

            with open(outputCsvPath, 'rb') as f_in, gzip.open(outputGzPath, 'wb') as f_out:
                f_out.writelines(f_in)

            os.remove(outputCsvPath)

            fileName = os.path.basename(outputGzPath)

            client = minioClient()
            client.upload_file(outputGzPath, fileName)

            os.remove(outputGzPath)
    except Exception as e:
        print(f"Error exportFile:{e}")
    finally:
        if(isClose == True):
            db.close()

def getMarketplaceIntance(db = dbContext(), isClose = False):
    print("Start function getMarketplaceIntance")

    try:
        query = f"""
            select * 
            from marketplace.t_instances ti
            where ti.effectived_date <= current_timestamp
            and (ti.expired_date >= current_timestamp or ti.expired_date is NULL)  
        """

        return db.executeQuery(query)
    except Exception as e:
        print(f"getMarketplaceIntance: {e}")
    finally:
        if(isClose == True):
            db.close()

def getMarketplaceProductById(db=dbContext(), productId = None, isClose = False):
    print("Start function getMarketplaceProductById")

    try:
        query = f"""
            select 
                mp.*,
                mv.code as vendor_code,
                mv.name as vendor_name
            from marketplace.m_products mp 
            inner join marketplace.m_vendors mv on mv.id = mp.vendor_id 
            where mp.id = '{productId}'
        """

        result = db.executeQuery(query)

        return result if result[0] else None
    except Exception as e:
        print(f"getMarketplaceProductById: {e}")
    finally:
        if(isClose == True):
            db.close()

def getMarketplaceInstancePeriod(db = dbContext(), period = None, instanceId = None, isClose = False):
    print("Start function getMarketplaceIntance_period")

    try:
        if period == None:
            period = getCurrentPeriod()
        
        query = f"""
            select * from marketplace.t_instance_usages tiu 
            where tiu.period = '{period}'
            and tiu.instance_id = '{instanceId}'
        """

        result = db.executeQuery(query)

        return result
    except Exception as e:
        print(f"Error in getMarketplaceInstancePeriod: {e}")
    finally:
        if(isClose == True):
            db.close()

def genMarketplaceInstancePeriod(db = dbContext(), period = None, instance = None, isClose = False):
    print("Starting function: genMarketplaceInstancePeriod")

    try:
        if period is None:
            period = getCurrentPeriod()

        firstDate, lastDate = getDateRange(period)

        product = getMarketplaceProductById(db=db, productId=instance.product_id)

        instance_usage = {
            "instance_id": instance.id,
            "period": period,
            "period_begin_date": firstDate,
            "period_end_date": lastDate,
            "usage": Decimal('0'),
            "usage_date": datetime.now(),
            "unblended_cost": Decimal('0'),
            "unblended_rate": Decimal(product[0].price_per_unit)
        }

        query = """
        INSERT INTO marketplace.t_instance_usages (
            instance_id,
            period,
            period_begin_date,
            period_end_date,
            usage,
            usage_date,
            unblended_cost,
            unblended_rate
        ) VALUES (
            %s, %s, %s, %s, %s, %s, %s, %s
        )
        """

        params = (
            instance_usage["instance_id"],
            instance_usage["period"],
            instance_usage["period_begin_date"],
            instance_usage["period_end_date"],
            instance_usage["usage"],
            instance_usage["usage_date"],
            instance_usage["unblended_cost"],
            instance_usage["unblended_rate"],
        )

        db.executeNonQuery(query, params)
        print("Marketplace Instance usage inserted successfully.")
    except Exception as e:
        print(f"Error genMarketplaceInstancePeriod: {e}")
    finally:
        if(isClose == True):
            db.close()

def updateMarketplaceInstancePeriod(db = dbContext(), period = None, instance = None, isClose = False):
    print("Starting function: updateMarketplaceInstancePeriod")

    try:
        if period is None:
            period = getCurrentPeriod()

        instanceUsage = getMarketplaceInstanceUsage(db=db, period=period, instance=instance)
        
        if not instanceUsage:
            print("No instance usage found for the provided parameters.")
            return
        
        instance = instanceUsage[0]
        instanceDict = {
            "id": instance.id,
            "usage": instance.usage,
            "unblended_rate": instance.unblended_rate,
            "unblended_cost": instance.unblended_cost
        }

        if instanceDict["usage"] == Decimal('0E-12') or instanceDict["usage"] == Decimal('0'):
            instanceDict["usage"] = Decimal(random.uniform(1.0, 100.0))
        else:
            randomPercentage = Decimal(getRandomPercentage())
            instanceDict["usage"] *= (1 + randomPercentage)

        instanceDict["unblended_cost"] = instanceDict["unblended_rate"] * instanceDict["usage"]

        query = """
            UPDATE marketplace.t_instance_usages
            SET 
                usage = %s, 
                unblended_cost = %s, 
                updated_date = current_timestamp
            WHERE id = %s 
            AND period = %s
        """

        params = (instanceDict["usage"], instanceDict["unblended_cost"], instanceDict["id"], period)

        db.executeNonQuery(query, params)
        print("Instance usage updated successfully.")
    except Exception as e:
        print(f"Error in updateMarketplaceInstancePeriod: {e}")

def getMarketplaceInstanceUsage(db = dbContext(), period = None, instance = None, isClose = False):
    print("Starting function: getMarketplaceInstanceUsage")

    try:
        if period is None:
            period = getCurrentPeriod()

        query = """
            SELECT *
            FROM marketplace.t_instance_usages
            WHERE instance_id = %s 
            AND period = %s
        """

        params = (
            instance.id,
            period
        )

        marketplaceInstanceUsage = db.executeQuery(query, params)

        return marketplaceInstanceUsage if marketplaceInstanceUsage[0] else None
    except Exception as e:
        print("Error in getMarketplaceInstanceUsage: {e}")
    finally:
        if isClose == True:
            db.close()

def main():
    print("Start project-1")

    try:
        db = dbContext()

        period = getCurrentPeriod()
        # period = '2024_11'

        instances = getInstances(db=db)
        
        if len(instances) > 0:
            for instance in instances:
                instancePeriod = getInstancePeriod(db=db, instanceId=instance.id, period=period)

                if(instancePeriod == None):
                    genInstancePeriod(db=db, instance=instance, period=period)

                updateInstancePeriod(db=db, instance=instance, period=period)
        
        marketplaceInstances = getMarketplaceIntance(db=db)
        
        if len(marketplaceInstances) > 0:
            for instance in marketplaceInstances:
                instancePeriod = getMarketplaceInstancePeriod(db=db, instanceId=instance.id, period=period)

                if(instancePeriod == None):
                    genMarketplaceInstancePeriod(db=db, instance=instance, period=period)

                updateMarketplaceInstancePeriod(db=db, instance=instance, period=period)

        query = """
            select * from master.m_accounts ma 
            where parent_account_id is null
        """

        parentAccounts = db.executeQuery(query)

        if len(parentAccounts) == 0:
            print("Data not found")
            return
        
        for parentAccount in parentAccounts:
            query = f"""
                select * from master.m_accounts ma
                where (id = '{parentAccount.id}' or parent_account_id = '{parentAccount.id}')
            """

            exportFile(db=db, parentAccountId=parentAccount.id, parentAccountCode=parentAccount.code, period=period)
    except Exception as e:
        print(f"Main Error: {e}")
    finally:
        db.close()
        print("Stop project-1")

if __name__ == "__main__":
    main()