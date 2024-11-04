import csv
import gzip
import os
import random

from datetime import datetime, timedelta
from decimal import Decimal
from app.common.dbContext import dbContext
from app.common.minioClient import minioClient

def get_instances(db = dbContext(), isClose = False):
    try:
        instances = db.execute_query("""
            select ti.* 
            from transaction.t_instances ti
            where ti.effectived_date <= current_timestamp
            and (ti.expired_date >= current_timestamp or ti.expired_date is NULL)                
        """)
            
        if(isClose == True):
            db.close()

        return instances
    except Exception as e:
        print(f"error in get_instances: {e}")

def get_instance_period(db = dbContext(), current_year_month = None, instance_id = None, isClose = False):
    print("Starting function: get_instance_period")

    try:
        if current_year_month == None:
            current_year_month = get_current_period()

        instance_usage = db.execute_query(f"""
            select * from transaction.t_instance_usages tiu 
            where tiu.period = '{current_year_month}'
            and tiu.instance_id = '{instance_id}'
        """)
        
        if(isClose == True):
            db.close()

        return instance_usage
    except Exception as e:
        print(f"get_instance_period: {e}")

def gen_instance_period(db = dbContext(), current_year_month = None, instance = None, isClose = False):
    print("Starting function: gen_instance_period")

    try:
        if current_year_month is None:
            current_year_month = get_current_period()

        pricing_model = get_instance_pricing_model(db=db, instance=instance)

        first_date, last_date = get_date_range(current_year_month)

        instance_usage = {
            "instance_id": instance.id,
            "pricing_model_id": instance.pricing_model_id,
            "period": current_year_month,
            "period_begin_date": first_date,
            "period_end_date": last_date,
            "usage": Decimal('0'),
            "usage_date": datetime.now(),
            "unblended_cost": Decimal('0'),
            "unblended_rate": Decimal(pricing_model[0].price_per_unit)
        }

        insert_query = """
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
            instance_usage["instance_id"],
            instance_usage["pricing_model_id"],
            instance_usage["period"],
            instance_usage["period_begin_date"],
            instance_usage["period_end_date"],
            instance_usage["usage"],
            instance_usage["usage_date"],
            instance_usage["unblended_cost"],
            instance_usage["unblended_rate"],
        )

        db.execute_non_query(insert_query, params)
        print("Instance usage inserted successfully.")
    except Exception as e:
        print(f"Error gen_instance_period: {e}")

def get_instance_pricing_model(db = dbContext(), instance = None, isClose = False):
    print("Start function: get_instance_pricing_model")

    try:
        pricing_model = db.execute_query(f"""
            select * from product.m_pricing_model mpm 
            where mpm.id = '{instance.pricing_model_id}'
        """)
    
        if(isClose == True):
            db.close()

        return pricing_model
    except:
        print()
    finally:
        db.close()

def get_random_percentage():
    return random.uniform(0.02, 0.05)

def update_instance_period(db = dbContext(), current_year_month = None, instance = None, isClose = False):
    print("Starting function: update_instance_period")

    try:
        if current_year_month is None:
            current_year_month = get_current_period()

        instance_usage = get_instance_usage(db=db, current_year_month=current_year_month, instance=instance)
        
        if not instance_usage:
            print("No instance usage found for the provided parameters.")
            return
        
        instance = instance_usage[0]
        instance_dict = {
            "id": instance.id,
            "usage": instance.usage,
            "unblended_rate": instance.unblended_rate,
            "unblended_cost": instance.unblended_cost
        }

        if instance_dict["usage"] == Decimal('0E-12') or instance_dict["usage"] == Decimal('0'):
            instance_dict["usage"] = Decimal(random.uniform(1.0, 100.0))
        else:
            random_percentage = Decimal(get_random_percentage())
            instance_dict["usage"] *= (1 + random_percentage)

        instance_dict["unblended_cost"] = instance_dict["unblended_rate"] * instance_dict["usage"]

        update_query = """
        UPDATE transaction.t_instance_usages
        SET 
            usage = %s, 
            unblended_cost = %s, 
            updated_date = current_timestamp
        WHERE id = %s 
        AND period = %s
        """

        update_params = (instance_dict["usage"], instance_dict["unblended_cost"], instance_dict["id"], current_year_month)
        db.execute_non_query(update_query, update_params)
        print("Instance usage updated successfully.")
    except Exception as e:
        print(f"Error in update_instance_period: {e}")

def get_instance_usage(db = dbContext(), current_year_month = None, instance = None, isClose = False):
    print("Starting function: get_instance_usage")

    try:
        if current_year_month is None:
            current_year_month = get_current_period()

        insert_query = """
            SELECT *
            FROM transaction.t_instance_usages
            WHERE instance_id = %s 
            AND period = %s
        """

        params = (
            instance.id,
            current_year_month
        )

        return db.execute_query(insert_query, params)
    except Exception as e:
        print("Error in get_instance_usage: {e}")

def get_account_transactions(db = dbContext(), isClose = False):
    try:
        results = db.execute_query("""
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

        if(len(results) > 0):
            if(isClose == True):
                db.close()

            return results
    except Exception as e:
        print(f"Error in get_account_transactions: {e}")

def get_date_range(period):
    year, month = map(int, period.split('_'))
    first_date = datetime(year, month, 1)
    
    if month == 12:
        last_date = datetime(year + 1, 1, 1) - timedelta(days=1)
    else:
        last_date = datetime(year, month + 1, 1) - timedelta(days=1)
    
    return first_date, last_date

def export_to_csv(db = dbContext(), current_year_month = None, parent_account_id = None, parent_account_code = None, isClose = False):
    print("Start function export_to_csv")

    if current_year_month == None:
        current_year_month = get_current_period()

    query = f"""
                (
                    SELECT 
                        tiu.id AS transaction_id,
                        tiu.period,
                        'AWS' AS entity,
                        'Usage' AS usage_type,
                        ma.code AS account_code,
                        ma.name AS account_name,
                        COALESCE(ma2.code, ma.code) AS parent_account_code,
                        tiu.unblended_cost AS unblended_cost,
                        tiu.unblended_rate,
                        ti.code AS instance_id,
                        ti.name AS instance_name,
                        mp.code AS product_code,
                        mp.name AS product_name,
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
                    WHERE (ma.id = '{parent_account_id}' OR ma.parent_account_id = '{parent_account_id}')
                    AND tiu.period = '{current_year_month}'
                )
                UNION ALL
                (
                    SELECT 
                        tiu.id AS transaction_id,
                        tiu.period,
                        'AWS' AS entity,
                        CASE 
                            WHEN COALESCE(parent_discount_program.code, mdp.code) IS NOT NULL THEN 
                                INITCAP(LOWER(COALESCE(parent_discount_program.code, mdp.code))) || ' Discount'
                            ELSE 
                                NULL
                        END AS usage_type,
                        ma.code AS account_code,
                        ma.name AS account_name,
                        COALESCE(ma2.code, ma.code) AS parent_account_code,
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
                    WHERE (ma.id = '{parent_account_id}' OR ma.parent_account_id = '{parent_account_id}')
                    AND tiu.period = '{current_year_month}'
                )
                UNION ALL
                (
                    SELECT 
                        tiu.id AS transaction_id,
                        tiu.period,
                        'AWS Marketplace' AS entity,
                        'Usage' AS usage_type,
                        ma.code AS account_code,
                        ma.name AS account_name,
                        COALESCE(ma2.code, ma.code) AS parent_account_code,
                        tiu.unblended_cost AS unblended_cost,
                        NULL AS unblended_rate,
                        ti.code AS instance_id,
                        ti.name AS instance_name,
                        mp.code AS product_code,
                        mp.name AS product_name,
                        NULL AS product_spec_code,
                        NULL AS product_spec_desc
                    FROM master.m_accounts ma
                    LEFT JOIN master.m_accounts ma2 ON ma.parent_account_id = ma2.id
                    INNER JOIN marketplace.t_instances ti ON ti.account_id = ma.id
                    INNER JOIN marketplace.m_products mp ON mp.id = ti.product_id
                    INNER JOIN marketplace.t_instance_usages tiu ON tiu.instance_id = ti.id
                    WHERE (ma.id = '{parent_account_id}' OR ma.parent_account_id = '{parent_account_id}')
                    AND tiu.period = '{current_year_month}'
                )
                ORDER BY 
                    account_code,
                    entity,
                    instance_id,
                    usage_type;
    """

    transactions = db.execute_query(query, (parent_account_id,))


    if transactions != None and len(transactions) > 0:
        output_dir = "transactions"
        os.makedirs(output_dir, exist_ok=True)

        output_csv_path = f"{output_dir}/{parent_account_code}_CUR_{current_year_month}.csv"
        print(f"Output CSV path: {output_csv_path}")

        output_gz_path = f"{output_csv_path}.gz"
        print(f"Gzip path: {output_gz_path}")

        column_names = db.get_column_names(query)

        try:
            with open(output_csv_path, mode='w', newline='') as csv_file:
                writer = csv.writer(csv_file)
                writer.writerow(column_names)
                writer.writerows(transactions)
            print(f"CSV file created at: {output_csv_path}")
        except Exception as e:
            print(f"Error writing CSV file: {e}")

        with open(output_csv_path, 'rb') as f_in, gzip.open(output_gz_path, 'wb') as f_out:
             f_out.writelines(f_in)

        os.remove(output_csv_path)

        file_name = os.path.basename(output_gz_path)

        client = minioClient()
        client.upload_file(output_gz_path, file_name)

        print(f"output_gz_path: {output_gz_path}")

        os.remove(output_gz_path)

def get_current_period():
    current_date = datetime.now()
    current_period = f"{current_date.year}_{current_date.month:02}"

    return current_period

def get_marketplace_intance(db = dbContext(), isClose = False):
    print("Start function get_marketplace_intance")

    try:
        instance_usage = db.execute_query(f"""
            select * 
            from marketplace.t_instances ti
            where ti.effectived_date <= current_timestamp
            and (ti.expired_date >= current_timestamp or ti.expired_date is NULL)  
        """)

        return instance_usage
    except Exception as e:
        print(f"get_instance_period: {e}")
    finally:
        if(isClose == True):
            db.close()

def get_marketplace_product_by_id(db=dbContext(), product_id = None, isClose = False):
    print("Start function get_marketplace_product_by_id")

    try:
        product = db.execute_query(f"""
            select 
                mp.*,
                mv.code as vendor_code,
                mv.name as vendor_name
            from marketplace.m_products mp 
            inner join marketplace.m_vendors mv on mv.id = mp.vendor_id 
            where mp.id = '{product_id}'
        """)
        
        if(isClose == True):
            db.close()

        return product if product[0] else None
    except Exception as e:
        print(f"get_instance_period: {e}")
    finally:
        if(isClose == True):
            db.close()

def get_marketplace_instance_period(db = dbContext(), current_year_month = None, instance_id = None, isClose = False):
    print("Start function get_marketplace_intance_period")

    try:
        if current_year_month == None:
            current_year_month = get_current_period()

        instance_usage = db.execute_query(f"""
            select * from marketplace.t_instance_usages tiu 
            where tiu.period = '{current_year_month}'
            and tiu.instance_id = '{instance_id}'
        """)
        

        return instance_usage
    except Exception as e:
        print(f"Error in get_instance_period: {e}")
    finally:
        if(isClose == True):
            db.close()

def gen_marketplace_instance_period(db = dbContext(), current_year_month = None, instance = None, isClose = False):
    print("Starting function: gen_marketplace_instance_period")

    try:
        if current_year_month is None:
            current_year_month = get_current_period()

        first_date, last_date = get_date_range(current_year_month)

        product = get_marketplace_product_by_id(db=db, product_id=instance.product_id)

        instance_usage = {
            "instance_id": instance.id,
            "period": current_year_month,
            "period_begin_date": first_date,
            "period_end_date": last_date,
            "usage": Decimal('0'),
            "usage_date": datetime.now(),
            "unblended_cost": Decimal('0'),
            "unblended_rate": Decimal(product[0].price_per_unit)
        }

        insert_query = """
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

        db.execute_non_query(insert_query, params)
        print("Marketplace Instance usage inserted successfully.")
    except Exception as e:
        print(f"Error gen_marketplace_instance_period: {e}")

def update_marketplace_instance_period(db = dbContext(), current_year_month = None, instance = None, isClose = False):
    print("Starting function: update_marketplace_instance_period")

    try:
        if current_year_month is None:
            current_year_month = get_current_period()

        instance_usage = get_marketplace_instance_usage(db=db, current_year_month=current_year_month, instance=instance)
        
        if not instance_usage:
            print("No instance usage found for the provided parameters.")
            return
        
        instance = instance_usage[0]
        instance_dict = {
            "id": instance.id,
            "usage": instance.usage,
            "unblended_rate": instance.unblended_rate,
            "unblended_cost": instance.unblended_cost
        }

        if instance_dict["usage"] == Decimal('0E-12') or instance_dict["usage"] == Decimal('0'):
            instance_dict["usage"] = Decimal(random.uniform(1.0, 100.0))
        else:
            random_percentage = Decimal(get_random_percentage())
            instance_dict["usage"] *= (1 + random_percentage)

        instance_dict["unblended_cost"] = instance_dict["unblended_rate"] * instance_dict["usage"]

        update_query = """
        UPDATE marketplace.t_instance_usages
        SET 
            usage = %s, 
            unblended_cost = %s, 
            updated_date = current_timestamp
        WHERE id = %s 
        AND period = %s
        """

        update_params = (instance_dict["usage"], instance_dict["unblended_cost"], instance_dict["id"], current_year_month)
        db.execute_non_query(update_query, update_params)
        print("Instance usage updated successfully.")
    except Exception as e:
        print(f"Error in update_instance_period: {e}")

def get_marketplace_instance_usage(db = dbContext(), current_year_month = None, instance = None, isClose = False):
    print("Starting function: get_marketplace_instance_usage")

    try:
        if current_year_month is None:
            current_year_month = get_current_period()

        insert_query = """
            SELECT *
            FROM marketplace.t_instance_usages
            WHERE instance_id = %s 
            AND period = %s
        """

        params = (
            instance.id,
            current_year_month
        )

        marketplace_instance_usage = db.execute_query(insert_query, params)

        return marketplace_instance_usage if marketplace_instance_usage[0] else None
    except Exception as e:
        print("Error in get_instance_usage: {e}")
    finally:
        if isClose == True:
            db.close()

def main():
    print("Start project-1")

    try:
        db = dbContext()

        period = get_current_period()
        period = '2024_11'

        instances = get_instances(db=db)
        
        if len(instances) > 0:
            for instance in instances:
                instance_period = get_instance_period(db=db, instance_id=instance.id, current_year_month=period)

                if(instance_period == None):
                    gen_instance_period(db=db, instance=instance, current_year_month=period)

                update_instance_period(db=db, instance=instance, current_year_month=period)
        
        marketplace_instances = get_marketplace_intance(db=db)
        
        if len(marketplace_instances) > 0:
            for instance in marketplace_instances:
                instance_period = get_marketplace_instance_period(db=db, instance_id=instance.id, current_year_month=period)

                if(instance_period == None):
                    gen_marketplace_instance_period(db=db, instance=instance, current_year_month=period)

                update_marketplace_instance_period(db=db, instance=instance, current_year_month=period)

        query = """
            select * from master.m_accounts ma 
            where parent_account_id is null
        """

        parent_accounts = db.execute_query(query)

        if len(parent_accounts) == 0:
            print("Data not found")
            return
        
        for parent_account in parent_accounts:
            query = f"""
                select * from master.m_accounts ma
                where (id = '{parent_account.id}' or parent_account_id = '{parent_account.id}')
            """

            export_to_csv(db=db, parent_account_id=parent_account.id, parent_account_code=parent_account.code, current_year_month=period)
            minio_client = minioClient()

    except Exception as e:
        print(f"Main Error: {e}")
    finally:
        db.close()
        print("Stop project-1")

if __name__ == "__main__":
    main()