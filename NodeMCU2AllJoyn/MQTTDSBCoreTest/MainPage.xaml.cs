using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;
using MQTTDSBCore;

// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace MQTTDSBCoreTest
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        MQTTDeviceManager manager = new MQTTDeviceManager("johnrp2", 1883);
        public MainPage()
        {
            this.InitializeComponent();
            manager.DeviceSignIn += Manager_DeviceSignIn;
        }

        private void Manager_DeviceSignIn(object sender, MQTTDevice e)
        {
            System.Diagnostics.Debug.WriteLine(string.Format("device {0} signin",e.Name));
        }

        private void btnReadJson_Click(object sender, RoutedEventArgs e)
        {
            var tmp = MQTTDSBCore.MQTTDevice.Create(System.Text.Encoding.UTF8.GetBytes(txtJson.Text));
        }

        private void btnStart_Click(object sender, RoutedEventArgs e)
        {
            manager.Start("uid", "pwd");
        }
    }
}
