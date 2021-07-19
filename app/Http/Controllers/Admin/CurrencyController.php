<?php

namespace App\Http\Controllers\Admin;

use App\CPU\Helpers;
use App\Http\Controllers\Controller;
use App\Model\BusinessSetting;
use App\Model\Currency;
use Brian2694\Toastr\Facades\Toastr;
use Illuminate\Http\Request;

class CurrencyController extends Controller
{
    public function index()
    {
        return view('admin-views.currency.view');
    }

    public function store(Request $request)
    {
        $currency = new Currency;
        $currency->name = $request->name;
        $currency->symbol = $request->symbol;
        $currency->code = $request->code;
        $currency->exchange_rate = $request->exchange_rate;
        $currency->save();
        Toastr::success('New Currency inserted successfully!');
        return redirect()->back();
    }

    public function update(Request $request)
    {
        $currency = Currency::find($request->id);
        if ($currency['code'] == 'BDT' && $request->code != 'BDT') {
            $config = Helpers::get_business_settings('ssl_commerz_payment');
            if ($config['status']) {
                Toastr::warning('Before update BDT, disable the SSLCOMMERZ payment gateway.');
                return back();
            }
        }elseif ($currency['code'] == 'INR' && $request->code != 'INR'){
            $config = Helpers::get_business_settings('razor_pay');
            if ($config['status']) {
                Toastr::warning('Before update INR, disable the RAZOR PAY payment gateway.');
                return back();
            }
        }elseif ($currency['code'] == 'MYR' && $request->code != 'MYR'){
            $config = Helpers::get_business_settings('senang_pay');
            if ($config['status']) {
                Toastr::warning('Before update MYR, disable the SENANG PAY payment gateway.');
                return back();
            }
        }elseif ($currency['code'] == 'ZAR' && $request->code != 'ZAR'){
            $config = Helpers::get_business_settings('paystack');
            if ($config['status']) {
                Toastr::warning('Before update ZAR, disable the PAYSTACK payment gateway.');
                return back();
            }
        }
        $currency->name = $request->name;
        $currency->symbol = $request->symbol;
        $currency->code = $request->code;
        $currency->exchange_rate = $request->exchange_rate;
        $currency->save();
        Toastr::success('Currency updated successfully!');
        return redirect()->back();
    }

    public function delete(Request $request)
    {
        Currency::destroy($request->id);
        return response()->json();
    }

    public function status(Request $request)
    {
        if ($request->ajax()) {
            $currency = Currency::find($request->id);
            $currency->status = $request->status;
            $currency->save();
        }
    }

    public function systemCurrencyUpdate(Request $request)
    {
        $business_settings = BusinessSetting::where('type', 'system_default_currency')->first();
        $business_settings->value = $request['currency_id'];
        $business_settings->save();

        $default = Currency::find($request['currency_id']);
        foreach (Currency::all() as $data) {
            Currency::where(['id' => $data['id']])->update([
                'exchange_rate' => ($data['exchange_rate'] / $default['exchange_rate']),
                'updated_at' => now()
            ]);
        }

        Toastr::success('System Default currency updated successfully!');
        return redirect()->back();
    }
}
