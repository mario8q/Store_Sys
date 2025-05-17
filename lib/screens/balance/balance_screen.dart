import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import './balance_controller.dart';

class BalanceScreen extends GetView<BalanceController> {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando datos del balance...'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Ingresos Totales',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  '\$${controller.totalIngresos.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Card(
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Egresos Totales',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Obx(
                                () => Text(
                                  '\$${controller.totalEgresos.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Card(
                  elevation: 4.0,
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Balance Actual',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        Obx(
                          () => Text(
                            '\$${controller.balanceActual.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color:
                                  controller.balanceActual.value >= 0
                                      ? Colors.green[900]
                                      : Colors.red[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Card(
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Distribución de Ingresos y Egresos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          height: 300,
                          child: Obx(() {
                            if (controller.totalIngresos.value == 0 &&
                                controller.totalEgresos.value == 0) {
                              return const Center(
                                child: Text('No hay datos para mostrar'),
                              );
                            }
                            return PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green[700],
                                    value: controller.totalIngresos.value,
                                    title:
                                        'Ingresos\n${(controller.totalIngresos.value / (controller.totalIngresos.value + controller.totalEgresos.value) * 100).toStringAsFixed(1)}%',
                                    radius: 100,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red[700],
                                    value: controller.totalEgresos.value,
                                    title:
                                        'Egresos\n${(controller.totalEgresos.value / (controller.totalIngresos.value + controller.totalEgresos.value) * 100).toStringAsFixed(1)}%',
                                    radius: 100,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 8),
                            const Text('Ingresos'),
                            const SizedBox(width: 24),
                            Container(
                              width: 16,
                              height: 16,
                              color: Colors.red[700],
                            ),
                            const SizedBox(width: 8),
                            const Text('Egresos'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
