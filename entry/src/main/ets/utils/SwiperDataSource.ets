export class SwiperDataSource implements IDataSource {
  private list: object[] = []

  constructor(list: object[]) {
    this.list = list
  }

  totalCount(): number {
    return this.list.length
  }

  getData(index: number): object {
    return this.list[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}